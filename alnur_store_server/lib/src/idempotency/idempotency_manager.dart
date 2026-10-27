import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Exception thrown when an idempotency key is reused with mismatched payload.
class IdempotencyConflictException implements Exception {
  final String message;
  const IdempotencyConflictException(this.message);

  @override
  String toString() => 'IdempotencyConflictException: $message';
}

/// Exception thrown when an identical request is already currently in-flight.
class IdempotencyInFlightException implements Exception {
  final String message;
  const IdempotencyInFlightException(this.message);

  @override
  String toString() => 'IdempotencyInFlightException: $message';
}

/// Centralized Enterprise Idempotency Framework for Serverpod.
///
/// Ensures critical mutating operations (Order placement, Payment webhooks,
/// Inventory adjustments, Checkout) are executed exactly once even during
/// network retries, duplicate client submissions, or parallel requests.
class IdempotencyManager {
  /// Generates a deterministic SHA-256 fingerprint for the request payload.
  static String generateRequestHash(
    String endpoint,
    Map<String, dynamic> requestData,
  ) {
    // Sort keys alphabetically for canonical JSON representation
    final sortedKeys = requestData.keys.toList()..sort();
    final canonicalMap = {
      for (final k in sortedKeys) k: _normalizeValue(requestData[k]),
    };
    final input = '$endpoint:${jsonEncode(canonicalMap)}';
    return sha256.convert(utf8.encode(input)).toString();
  }

  static dynamic _normalizeValue(dynamic val) {
    if (val is Map) {
      final sorted = val.keys.toList()..sort();
      return {for (final k in sorted) k: _normalizeValue(val[k])};
    } else if (val is List) {
      return val.map(_normalizeValue).toList();
    }
    return val;
  }

  /// Executes [action] with enterprise idempotency guarantees.
  ///
  /// - If [idempotencyKey] is null or empty, [action] executes normally.
  /// - If a record exists with status `completed` and valid TTL, the cached
  ///   response is returned immediately without executing [action].
  /// - If the key is reused with a different request payload, an
  ///   [IdempotencyConflictException] is thrown.
  /// - If another process is currently executing the request within [lockTimeout],
  ///   an [IdempotencyInFlightException] is thrown.
  static Future<T> run<T>({
    required Session session,
    required String? idempotencyKey,
    required String endpoint,
    required Map<String, dynamic> requestData,
    required Future<T> Function() action,
    required String Function(T result) toJson,
    required T Function(String json) fromJson,
    Duration ttl = const Duration(hours: 24),
    Duration lockTimeout = const Duration(seconds: 45),
  }) async {
    // Fallback: If no idempotency key provided, execute action directly
    if (idempotencyKey == null || idempotencyKey.trim().isEmpty) {
      return await action();
    }

    final cleanKey = idempotencyKey.trim();
    final requestHash = generateRequestHash(endpoint, requestData);
    final now = DateTime.now();

    // 1. Look up existing idempotency record
    final existingRecord = await IdempotencyRecord.db.findFirstRow(
      session,
      where: (t) => t.key.equals(cleanKey),
    );

    if (existingRecord != null) {
      // Check expiration
      if (existingRecord.expiresAt.isBefore(now)) {
        // Expired record: delete and proceed fresh
        await IdempotencyRecord.db.deleteRow(session, existingRecord);
      } else {
        // Payload mismatch check
        if (existingRecord.requestHash != requestHash) {
          session.log(
            'Idempotency key mismatch for key: $cleanKey. Expected hash: ${existingRecord.requestHash}, got: $requestHash',
            level: LogLevel.warning,
          );
          throw IdempotencyConflictException(
            'Idempotency key "$cleanKey" was previously submitted with a different request payload.',
          );
        }

        // Return cached response if completed
        if (existingRecord.status == 'completed' &&
            existingRecord.responseJson != null) {
          session.log(
            'Returning cached idempotent response for key: $cleanKey ($endpoint)',
            level: LogLevel.info,
          );
          return fromJson(existingRecord.responseJson!);
        }

        // Check if currently locked / in-flight
        if (existingRecord.status == 'pending') {
          final lockedAt = existingRecord.lockedAt ?? existingRecord.createdAt;
          if (now.difference(lockedAt) < lockTimeout) {
            session.log(
              'Duplicate request in-flight for key: $cleanKey ($endpoint)',
              level: LogLevel.warning,
            );
            throw IdempotencyInFlightException(
              'A request with idempotency key "$cleanKey" is currently in-progress. Please wait.',
            );
          } else {
            // Lock expired (e.g. previous worker crashed) -> reclaim lock
            session.log(
              'Reclaiming expired lock on idempotency key: $cleanKey',
              level: LogLevel.warning,
            );
            existingRecord.lockedAt = now;
            await IdempotencyRecord.db.updateRow(session, existingRecord);
          }
        }
      }
    }

    // 2. Create or acquire pending idempotency record
    IdempotencyRecord activeRecord;
    if (existingRecord == null || existingRecord.expiresAt.isBefore(now)) {
      activeRecord = await IdempotencyRecord.db.insertRow(
        session,
        IdempotencyRecord(
          key: cleanKey,
          endpoint: endpoint,
          requestHash: requestHash,
          status: 'pending',
          createdAt: now,
          lockedAt: now,
          expiresAt: now.add(ttl),
        ),
      );
    } else {
      activeRecord = existingRecord;
    }

    // 3. Execute the mutating action
    try {
      final result = await action();

      // Serialize and complete record
      activeRecord.status = 'completed';
      activeRecord.responseJson = toJson(result);
      activeRecord.statusCode = 200;
      await IdempotencyRecord.db.updateRow(session, activeRecord);

      return result;
    } catch (error) {
      // Mark as failed so future retries can proceed
      activeRecord.status = 'failed';
      activeRecord.errorMessage = error.toString();
      await IdempotencyRecord.db.updateRow(session, activeRecord);
      rethrow;
    }
  }

  /// Cleans up expired idempotency records from PostgreSQL.
  static Future<int> cleanupExpired(Session session) async {
    final now = DateTime.now();
    final expired = await IdempotencyRecord.db.find(
      session,
      where: (t) => t.expiresAt < now,
    );

    for (final record in expired) {
      await IdempotencyRecord.db.deleteRow(session, record);
    }
    return expired.length;
  }
}
