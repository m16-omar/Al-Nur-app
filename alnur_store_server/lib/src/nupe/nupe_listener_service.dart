import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart' show Argon2HashUtil, Argon2HashParameters;

import '../generated/protocol.dart';

/// Accounts, tokens and presence for Nupe Songs app listeners.
///
/// Listeners are stored in the `nupe_listener` table and are completely
/// separate from Al-Nur Store customers and from the Nupe Studio admin.
///
/// Tokens are stateless and HMAC-signed (`nl1.<payload>.<signature>`), so they
/// survive server restarts and redeploys without a token table.
class NupeListenerService {
  NupeListenerService._();

  static const accessTtl = Duration(hours: 12);
  static const refreshTtl = Duration(days: 60);

  /// A listener counts as "online" if seen within this window.
  static const onlineWindow = Duration(minutes: 5);

  /// Minimum gap between presence writes for the same listener.
  static const _presenceWriteGap = Duration(seconds: 60);

  static const _tokenPrefix = 'nl1';

  static final Random _random = Random.secure();
  static final Map<int, DateTime> _lastPresenceWrite = {};
  static List<int>? _fallbackSecret;

  // ---------------------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------------------

  static final RegExp _usernamePattern = RegExp(r'^[a-z0-9_.]{3,30}$');
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String normalizeUsername(String value) => value.trim().toLowerCase();
  static String normalizeEmail(String value) => value.trim().toLowerCase();

  /// Returns field -> messages for invalid registration input (empty if valid).
  static Map<String, List<String>> validateRegistration({
    required String username,
    required String email,
    required String password,
  }) {
    final errors = <String, List<String>>{};
    if (!_usernamePattern.hasMatch(username)) {
      errors['username'] = [
        'Username must be 3–30 characters: letters, numbers, "_" or ".".'
      ];
    }
    if (!_emailPattern.hasMatch(email)) {
      errors['email'] = ['Enter a valid email address.'];
    }
    if (password.length < 6) {
      errors['password'] = ['Password must be at least 6 characters.'];
    }
    return errors;
  }

  // ---------------------------------------------------------------------------
  // Password hashing
  //
  // New hashes use Argon2id (OWASP minimum: 19 MiB memory, 2 passes, 1 lane)
  // in PHC format ("$argon2id$..."), computed in a background isolate.
  // Older PBKDF2-HMAC-SHA256 hashes ("60000$salt$hash") still verify and are
  // upgraded to Argon2id on the next successful sign-in.
  // ---------------------------------------------------------------------------

  static final Argon2HashUtil _argon2 = Argon2HashUtil(
    hashPepper: 'nupe-listener-v1',
    hashSaltLength: 16,
    parameters: Argon2HashParameters(memory: 19456, iterations: 2, lanes: 1),
  );

  static Future<String> hashPassword(String password) =>
      _argon2.createHashFromString(secret: password);

  /// True for hashes that should be upgraded to Argon2id.
  static bool needsRehash(String stored) => !stored.startsWith(r'$argon2');

  static Future<bool> verifyPassword(String password, String stored) async {
    if (stored.startsWith(r'$argon2')) {
      return _argon2.validateHashFromString(secret: password, hashString: stored);
    }
    return _verifyLegacyPbkdf2(password, stored);
  }

  /// Burns comparable time when an account does not exist, so response time
  /// does not reveal which usernames/emails are registered.
  static Future<void> dummyVerify(String password) async {
    _dummyHash ??= await hashPassword('dummy-password-for-timing');
    await verifyPassword(password, _dummyHash!);
  }

  static String? _dummyHash;

  static bool _verifyLegacyPbkdf2(String password, String stored) {
    final parts = stored.split(r'$');
    if (parts.length != 3) return false;
    final iterations = int.tryParse(parts[0]);
    if (iterations == null || iterations < 1) return false;
    final salt = base64.decode(parts[1]);
    final expected = base64.decode(parts[2]);
    final actual =
        _pbkdf2(utf8.encode(password), salt, iterations, expected.length);
    return _constantTimeEquals(actual, expected);
  }

  static List<int> _pbkdf2(
      List<int> password, List<int> salt, int iterations, int keyLength) {
    final hmac = Hmac(sha256, password);
    final out = <int>[];
    var block = 1;
    while (out.length < keyLength) {
      final blockIndex = [
        (block >> 24) & 0xff,
        (block >> 16) & 0xff,
        (block >> 8) & 0xff,
        block & 0xff,
      ];
      var u = hmac.convert([...salt, ...blockIndex]).bytes;
      final t = List<int>.from(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      out.addAll(t);
      block++;
    }
    return out.sublist(0, keyLength);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    var diff = a.length ^ b.length;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ (i < b.length ? b[i] : 0);
    }
    return diff == 0;
  }

  // ---------------------------------------------------------------------------
  // Tokens
  // ---------------------------------------------------------------------------

  static List<int> _secret(Session session) {
    final configured = session.passwords['nupeListenerTokenSecret'] ??
        session.passwords['serviceSecret'];
    if (configured != null && configured.isNotEmpty) {
      return utf8.encode('nupe-listener:$configured');
    }
    // Last resort: tokens stay valid only until the next restart.
    if (_fallbackSecret == null) {
      session.log(
        'No serviceSecret/nupeListenerTokenSecret configured; Nupe listener '
        'tokens will be invalidated on restart.',
        level: LogLevel.warning,
      );
      _fallbackSecret = List<int>.generate(32, (_) => _random.nextInt(256));
    }
    return _fallbackSecret!;
  }

  static String _b64(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  static List<int> _unb64(String value) =>
      base64Url.decode(value.padRight((value.length + 3) ~/ 4 * 4, '='));

  static String _issue(Session session, int listenerId, String type, Duration ttl) {
    final payload = _b64(utf8.encode(jsonEncode({
      'sub': listenerId,
      'typ': type,
      'exp': DateTime.now().toUtc().add(ttl).millisecondsSinceEpoch ~/ 1000,
      'n': _b64(List<int>.generate(6, (_) => _random.nextInt(256))),
    })));
    final signature =
        _b64(Hmac(sha256, _secret(session)).convert(utf8.encode(payload)).bytes);
    return '$_tokenPrefix.$payload.$signature';
  }

  static ({String access, String refresh}) issueTokens(
      Session session, int listenerId) {
    return (
      access: _issue(session, listenerId, 'access', accessTtl),
      refresh: _issue(session, listenerId, 'refresh', refreshTtl),
    );
  }

  static bool looksLikeListenerToken(String token) =>
      token.startsWith('$_tokenPrefix.');

  /// Returns the listener id if [token] is a valid, unexpired token of [type].
  static int? verifyToken(Session session, String token, {String type = 'access'}) {
    final parts = token.split('.');
    if (parts.length != 3 || parts[0] != _tokenPrefix) return null;
    try {
      final expected =
          Hmac(sha256, _secret(session)).convert(utf8.encode(parts[1])).bytes;
      if (!_constantTimeEquals(_unb64(parts[2]), expected)) return null;
      final data = jsonDecode(utf8.decode(_unb64(parts[1]))) as Map<String, dynamic>;
      if (data['typ'] != type) return null;
      final exp = data['exp'] as int;
      if (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 >= exp) return null;
      return data['sub'] as int;
    } catch (_) {
      return null;
    }
  }

  /// Reads a Bearer listener access token from the request, if any.
  static int? listenerIdFromRequest(Session session, Request request) {
    String? token;
    try {
      final header = request.headers.authorization;
      if (header is BearerAuthorizationHeader) token = header.token;
    } catch (_) {
      return null;
    }
    if (token == null || !looksLikeListenerToken(token)) return null;
    return verifyToken(session, token);
  }

  // ---------------------------------------------------------------------------
  // Presence
  // ---------------------------------------------------------------------------

  /// Records that [listenerId] is active. Writes are throttled unless an
  /// [activity] or [platform] is provided.
  static Future<void> touch(
    Session session,
    int listenerId, {
    String? activity,
    String? platform,
  }) async {
    final now = DateTime.now().toUtc();
    final last = _lastPresenceWrite[listenerId];
    final hasDetail = activity != null || platform != null;
    if (!hasDetail && last != null && now.difference(last) < _presenceWriteGap) {
      return;
    }
    _lastPresenceWrite[listenerId] = now;
    try {
      final listener = await NupeListener.db.findById(session, listenerId);
      if (listener == null || listener.isDisabled) return;
      listener.lastSeenAt = now;
      if (activity != null) listener.lastActivity = _clip(activity, 120);
      if (platform != null) listener.platform = _clip(platform, 30);
      await NupeListener.db.updateRow(
        session,
        listener,
        columns: (t) => [t.lastSeenAt, t.lastActivity, t.platform],
      );
    } catch (e) {
      session.log('Nupe presence update failed: $e', level: LogLevel.warning);
    }
  }

  static String _clip(String value, int max) {
    final v = value.trim();
    return v.length <= max ? v : v.substring(0, max);
  }

  static const signedOutActivity = 'Signed out';

  static bool isOnline(NupeListener listener, [DateTime? now]) {
    final seen = listener.lastSeenAt;
    if (seen == null || listener.lastActivity == signedOutActivity) return false;
    return (now ?? DateTime.now().toUtc()).difference(seen) <= onlineWindow;
  }

  static Future<int> countOnline(Session session) {
    final cutoff = DateTime.now().toUtc().subtract(onlineWindow);
    return NupeListener.db.count(
      session,
      where: (t) =>
          (t.lastSeenAt > cutoff) &
          t.isDisabled.equals(false) &
          (t.lastActivity.equals(null) | t.lastActivity.notEquals(signedOutActivity)),
    );
  }

  // ---------------------------------------------------------------------------
  // JSON shapes
  // ---------------------------------------------------------------------------

  static String fullName(NupeListener l) {
    final name = [l.firstName, l.lastName]
        .where((p) => p != null && p.trim().isNotEmpty)
        .join(' ')
        .trim();
    return name.isEmpty ? l.username : name;
  }

  /// Profile returned to the listener app (`/api/auth/me`).
  static Map<String, dynamic> toProfileJson(NupeListener l) => {
        'id': l.id,
        'username': l.username,
        'email': l.email,
        'full_name': fullName(l),
        'first_name': l.firstName ?? '',
        'last_name': l.lastName ?? '',
        'is_staff': false,
        'date_joined': l.createdAt.toUtc().toIso8601String(),
      };

  /// Row returned to the Nupe Studio admin (never includes the password hash).
  static Map<String, dynamic> toAdminJson(NupeListener l, DateTime now) => {
        'id': l.id,
        'username': l.username,
        'email': l.email,
        'full_name': fullName(l),
        'created_at': l.createdAt.toUtc().toIso8601String(),
        'last_seen_at': l.lastSeenAt?.toUtc().toIso8601String(),
        'last_activity': l.lastActivity,
        'platform': l.platform,
        'is_online': !l.isDisabled && isOnline(l, now),
        'is_disabled': l.isDisabled,
      };
}
