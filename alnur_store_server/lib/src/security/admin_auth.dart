import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

/// Server-side authentication for the Al-Nur Store admin panel (/admin).
///
/// Credentials are read from Serverpod passwords (Serverpod Cloud →
/// Env & Passwords, or `config/passwords.yaml` locally):
///
/// * `alnurAdminEmail`    – admin login email
/// * `alnurAdminPassword` – admin login password
/// * `alnurAdminName`     – optional display name
///
/// Outside production a development default is used when they are not set,
/// production refuses to log anyone in until they are configured.
///
/// Tokens are HMAC-signed (`aa1.<payload>.<signature>`) so they survive
/// restarts. The signing key includes a fingerprint of the admin password,
/// so changing the password signs every admin out.
class AlnurAdminAuth {
  AlnurAdminAuth._();

  /// Scope carried by authenticated Al-Nur admin requests.
  static const scope = Scope('alnur.admin');

  static const _tokenPrefix = 'aa1';
  static const _devEmail = 'admin@alnur.store';
  static const _devPassword = 'alnur-dev-admin';
  static const sessionTtl = Duration(hours: 12);
  static const rememberTtl = Duration(days: 7);

  static final Random _random = Random.secure();
  static List<int>? _fallbackSecret;

  /// Logged-out token ids -> expiry (so a stolen token can't be reused after
  /// logout until it would have expired anyway).
  static final Map<String, DateTime> _revoked = {};

  static String? _password(String name) {
    try {
      final v = Serverpod.instance.getPassword(name);
      return (v == null || v.trim().isEmpty) ? null : v;
    } catch (_) {
      return null;
    }
  }

  static bool get _isProduction {
    try {
      return Serverpod.instance.runMode == ServerpodRunMode.production;
    } catch (_) {
      return true;
    }
  }

  /// The configured admin account, or null if none is configured (production).
  static ({String email, String password, String name})? credentials() {
    final email = _password('alnurAdminEmail')?.trim().toLowerCase();
    final password = _password('alnurAdminPassword');
    final name = _password('alnurAdminName')?.trim() ?? 'Store Administrator';
    if (email != null && password != null) {
      return (email: email, password: password, name: name);
    }
    if (_isProduction) return null;
    return (email: _devEmail, password: _devPassword, name: name);
  }

  static bool isConfigured() => credentials() != null;

  static List<int> _signingKey(String password) {
    var secret = _password('alnurAdminTokenSecret') ?? _password('serviceSecret');
    List<int> base;
    if (secret != null) {
      base = utf8.encode(secret);
    } else {
      _fallbackSecret ??= List<int>.generate(32, (_) => _random.nextInt(256));
      base = _fallbackSecret!;
    }
    final pwFingerprint = sha256.convert(utf8.encode(password)).bytes;
    return sha256.convert([...utf8.encode('alnur-admin-v1:'), ...base, ...pwFingerprint]).bytes;
  }

  static bool secureEquals(String a, String b) {
    final aa = utf8.encode(a);
    final bb = utf8.encode(b);
    var diff = aa.length ^ bb.length;
    for (var i = 0; i < aa.length; i++) {
      diff |= aa[i] ^ (i < bb.length ? bb[i] : 0);
    }
    return diff == 0;
  }

  static String _b64(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');
  static List<int> _unb64(String v) =>
      base64Url.decode(v.padRight((v.length + 3) ~/ 4 * 4, '='));

  /// Checks credentials and returns a signed token, or null if they are wrong.
  static ({String token, DateTime expiresAt, String email, String name})? login(
    String email,
    String password, {
    bool remember = false,
  }) {
    final creds = credentials();
    if (creds == null) return null;
    final emailOk = secureEquals(email.trim().toLowerCase(), creds.email);
    final passwordOk = secureEquals(password, creds.password);
    if (!emailOk || !passwordOk) return null;

    final expiresAt = DateTime.now().toUtc().add(remember ? rememberTtl : sessionTtl);
    final payload = _b64(utf8.encode(jsonEncode({
      'sub': creds.email,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
      'jti': _b64(List<int>.generate(12, (_) => _random.nextInt(256))),
    })));
    final sig = _b64(Hmac(sha256, _signingKey(creds.password)).convert(utf8.encode(payload)).bytes);
    return (
      token: '$_tokenPrefix.$payload.$sig',
      expiresAt: expiresAt,
      email: creds.email,
      name: creds.name,
    );
  }

  static bool looksLikeAdminToken(String token) => token.startsWith('$_tokenPrefix.');

  /// Verifies [token]. Returns its claims, or null when invalid/expired/revoked.
  static ({String email, String jti, DateTime expiresAt})? verify(String token) {
    final creds = credentials();
    if (creds == null) return null;
    final parts = token.split('.');
    if (parts.length != 3 || parts[0] != _tokenPrefix) return null;
    try {
      final expected = Hmac(sha256, _signingKey(creds.password)).convert(utf8.encode(parts[1])).bytes;
      final given = _unb64(parts[2]);
      var diff = expected.length ^ given.length;
      for (var i = 0; i < expected.length; i++) {
        diff |= expected[i] ^ (i < given.length ? given[i] : 0);
      }
      if (diff != 0) return null;
      final data = jsonDecode(utf8.decode(_unb64(parts[1]))) as Map<String, dynamic>;
      final email = data['sub'] as String;
      if (email != creds.email) return null;
      final exp = DateTime.fromMillisecondsSinceEpoch((data['exp'] as int) * 1000, isUtc: true);
      if (!exp.isAfter(DateTime.now().toUtc())) return null;
      final jti = data['jti'] as String;
      _purgeRevoked();
      if (_revoked.containsKey(jti)) return null;
      return (email: email, jti: jti, expiresAt: exp);
    } catch (_) {
      return null;
    }
  }

  /// Authentication handler hook: turns a valid admin token into an
  /// [AuthenticationInfo] carrying [scope].
  static AuthenticationInfo? authenticate(String token) {
    final claims = verify(token);
    if (claims == null) return null;
    return AuthenticationInfo('alnur-admin:${claims.email}', {scope}, authId: claims.jti);
  }

  /// Revokes [token] (logout).
  static void revoke(String token) {
    final claims = verify(token);
    if (claims != null) _revoked[claims.jti] = claims.expiresAt;
  }

  static void _purgeRevoked() {
    final now = DateTime.now().toUtc();
    _revoked.removeWhere((_, exp) => !exp.isAfter(now));
  }

  /// True when the current call carries a valid Al-Nur admin token.
  static bool isAdmin(Session session) {
    final info = session.authenticated;
    return info != null && info.scopes.contains(scope);
  }

  /// Throws a 401/403 unless the call is from a signed-in Al-Nur admin.
  static void requireAdmin(Session session) {
    final info = session.authenticated;
    if (info == null) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.unauthenticated,
        message: 'Admin sign-in required.',
      );
    }
    if (!info.scopes.contains(scope)) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Admin access required.',
      );
    }
  }

  /// Raw bearer token from the current request, if any.
  static String? bearerToken(Session session) {
    try {
      final Request? request = session is MethodCallSession
          ? session.request
          : (session is WebCallSession ? session.request : null);
      final header = request?.headers.authorization;
      if (header is BearerAuthorizationHeader) return header.token;
    } catch (_) {}
    return null;
  }
}
