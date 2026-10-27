/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class IdempotencyRecord implements _i1.SerializableModel {
  IdempotencyRecord._({
    this.id,
    required this.key,
    required this.endpoint,
    required this.requestHash,
    required this.status,
    this.responseJson,
    this.statusCode,
    this.errorMessage,
    required this.createdAt,
    this.lockedAt,
    required this.expiresAt,
  });

  factory IdempotencyRecord({
    int? id,
    required String key,
    required String endpoint,
    required String requestHash,
    required String status,
    String? responseJson,
    int? statusCode,
    String? errorMessage,
    required DateTime createdAt,
    DateTime? lockedAt,
    required DateTime expiresAt,
  }) = _IdempotencyRecordImpl;

  factory IdempotencyRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return IdempotencyRecord(
      id: jsonSerialization['id'] as int?,
      key: jsonSerialization['key'] as String,
      endpoint: jsonSerialization['endpoint'] as String,
      requestHash: jsonSerialization['requestHash'] as String,
      status: jsonSerialization['status'] as String,
      responseJson: jsonSerialization['responseJson'] as String?,
      statusCode: jsonSerialization['statusCode'] as int?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      lockedAt: jsonSerialization['lockedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lockedAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String key;

  String endpoint;

  String requestHash;

  String status;

  String? responseJson;

  int? statusCode;

  String? errorMessage;

  DateTime createdAt;

  DateTime? lockedAt;

  DateTime expiresAt;

  /// Returns a shallow copy of this [IdempotencyRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IdempotencyRecord copyWith({
    int? id,
    String? key,
    String? endpoint,
    String? requestHash,
    String? status,
    String? responseJson,
    int? statusCode,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? lockedAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IdempotencyRecord',
      if (id != null) 'id': id,
      'key': key,
      'endpoint': endpoint,
      'requestHash': requestHash,
      'status': status,
      if (responseJson != null) 'responseJson': responseJson,
      if (statusCode != null) 'statusCode': statusCode,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'createdAt': createdAt.toJson(),
      if (lockedAt != null) 'lockedAt': lockedAt?.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IdempotencyRecordImpl extends IdempotencyRecord {
  _IdempotencyRecordImpl({
    int? id,
    required String key,
    required String endpoint,
    required String requestHash,
    required String status,
    String? responseJson,
    int? statusCode,
    String? errorMessage,
    required DateTime createdAt,
    DateTime? lockedAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         key: key,
         endpoint: endpoint,
         requestHash: requestHash,
         status: status,
         responseJson: responseJson,
         statusCode: statusCode,
         errorMessage: errorMessage,
         createdAt: createdAt,
         lockedAt: lockedAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [IdempotencyRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IdempotencyRecord copyWith({
    Object? id = _Undefined,
    String? key,
    String? endpoint,
    String? requestHash,
    String? status,
    Object? responseJson = _Undefined,
    Object? statusCode = _Undefined,
    Object? errorMessage = _Undefined,
    DateTime? createdAt,
    Object? lockedAt = _Undefined,
    DateTime? expiresAt,
  }) {
    return IdempotencyRecord(
      id: id is int? ? id : this.id,
      key: key ?? this.key,
      endpoint: endpoint ?? this.endpoint,
      requestHash: requestHash ?? this.requestHash,
      status: status ?? this.status,
      responseJson: responseJson is String? ? responseJson : this.responseJson,
      statusCode: statusCode is int? ? statusCode : this.statusCode,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      lockedAt: lockedAt is DateTime? ? lockedAt : this.lockedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
