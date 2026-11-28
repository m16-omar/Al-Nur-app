import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import 'admin_auth.dart';
import 'rate_limiter.dart';

/// Login / session endpoints for the Al-Nur Store admin panel.
///
/// Returns JSON strings so the plain-JavaScript admin page can use them
/// without a generated client.
class AdminAuthEndpoint extends Endpoint {
  /// Signs in with the configured admin credentials.
  ///
  /// Locked for 15 minutes after 5 failed attempts for an email or 10 from one IP.
  Future<String> login(
    Session session, {
    required String email,
    required String password,
    bool? remember,
  }) async {
    final ip = clientIpOf(session);
    final cleanEmail = email.trim().toLowerCase();
    final ipKey = 'admin-login-ip|$ip';
    final emailKey = 'admin-login-email|$cleanEmail';
    const window = Duration(minutes: 15);
    if (RateLimiter.isBlocked(ipKey, max: 10) ||
        RateLimiter.isBlocked(emailKey, max: 5)) {
      return jsonEncode({
        'ok': false,
        'error': 'Too many sign-in attempts. Try again in a few minutes.',
      });
    }

    if (!AlnurAdminAuth.isConfigured()) {
      return jsonEncode({
        'ok': false,
        'error': 'The admin account is not configured on this server.',
      });
    }

    final result = AlnurAdminAuth.login(cleanEmail, password, remember: remember ?? false);
    if (result == null) {
      // Count only failures.
      RateLimiter.hit(ipKey, max: 1 << 30, window: window);
      RateLimiter.hit(emailKey, max: 1 << 30, window: window);
      session.log('Failed Al-Nur admin sign-in from $ip', level: LogLevel.warning);
      return jsonEncode({'ok': false, 'error': 'Invalid admin email or password.'});
    }
    RateLimiter.reset(emailKey);
    return jsonEncode({
      'ok': true,
      'token': result.token,
      'expires_at': result.expiresAt.toIso8601String(),
      'user': {'email': result.email, 'name': result.name, 'role': 'Super Administrator'},
    });
  }

  /// Returns the signed-in admin, or `{ok:false}` if the token is invalid.
  Future<String> me(Session session) async {
    if (!AlnurAdminAuth.isAdmin(session)) {
      return jsonEncode({'ok': false});
    }
    final creds = AlnurAdminAuth.credentials();
    return jsonEncode({
      'ok': true,
      'user': {
        'email': creds?.email,
        'name': creds?.name ?? 'Store Administrator',
        'role': 'Super Administrator',
      },
    });
  }

  /// Revokes the current admin token.
  Future<bool> logout(Session session) async {
    final token = AlnurAdminAuth.bearerToken(session);
    if (token != null) AlnurAdminAuth.revoke(token);
    return true;
  }
}
