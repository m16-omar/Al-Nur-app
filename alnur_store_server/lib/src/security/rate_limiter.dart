import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Small in-memory, fixed-window rate limiter.
///
/// Counters live in this server process only, so limits reset on restart and
/// are per instance. That is enough to stop brute-force and spam bursts
/// without needing Redis.
class RateLimiter {
  RateLimiter._();

  static final Map<String, _Window> _windows = {};
  static DateTime _lastPurge = DateTime.now();

  /// Records one hit for [key]. Returns `true` if the request is allowed,
  /// `false` if [max] hits were already made within [window].
  static bool hit(String key, {required int max, required Duration window}) {
    final now = DateTime.now();
    _purge(now);
    final w = _windows[key];
    if (w == null || now.isAfter(w.resetAt)) {
      _windows[key] = _Window(1, now.add(window));
      return true;
    }
    if (w.count >= max) return false;
    w.count++;
    return true;
  }

  /// True when [key] has already used [max] hits in its current window
  /// (does not record a hit). Use with [hit] to count only failures.
  static bool isBlocked(String key, {required int max}) {
    final w = _windows[key];
    if (w == null || DateTime.now().isAfter(w.resetAt)) return false;
    return w.count >= max;
  }

  /// Seconds until [key] may be used again (0 if not limited).
  static int retryAfterSeconds(String key) {
    final w = _windows[key];
    if (w == null) return 0;
    final s = w.resetAt.difference(DateTime.now()).inSeconds;
    return s < 0 ? 0 : s + 1;
  }

  /// Clears the counter for [key] (e.g. after a successful login).
  static void reset(String key) => _windows.remove(key);

  static void _purge(DateTime now) {
    if (now.difference(_lastPurge) < const Duration(minutes: 5)) return;
    _lastPurge = now;
    _windows.removeWhere((_, w) => now.isAfter(w.resetAt));
  }

  /// Rate-limits a Serverpod endpoint call. Throws [RateLimitException]
  /// (sent to the client as a typed exception) when the limit is exceeded.
  static void enforce(
    Session session,
    String bucket, {
    required int max,
    required Duration window,
    String? identity,
  }) {
    final key = '$bucket|${identity ?? clientIpOf(session)}';
    if (!hit(key, max: max, window: window)) {
      throw RateLimitException(
        message: 'Too many requests. Please wait a moment and try again.',
        retryAfterSeconds: retryAfterSeconds(key),
      );
    }
  }
}

class _Window {
  _Window(this.count, this.resetAt);
  int count;
  final DateTime resetAt;
}

/// Best-effort client IP for a request.
///
/// Serverpod Cloud runs behind a load balancer, so the first
/// `X-Forwarded-For` entry is the original client. Falls back to the socket
/// address for direct connections (local development).
String clientIpOf(Object sessionOrRequest) {
  Request? request;
  if (sessionOrRequest is Request) {
    request = sessionOrRequest;
  } else if (sessionOrRequest is MethodCallSession) {
    request = sessionOrRequest.request;
  } else if (sessionOrRequest is WebCallSession) {
    request = sessionOrRequest.request;
  }
  if (request == null) return 'unknown';
  try {
    final forwarded = request.headers['x-forwarded-for'];
    if (forwarded != null && forwarded.isNotEmpty) {
      final first = forwarded.first.split(',').first.trim();
      if (first.isNotEmpty) return first;
    }
  } catch (_) {}
  try {
    return request.connectionInfo.remote.address.toString();
  } catch (_) {
    return 'unknown';
  }
}
