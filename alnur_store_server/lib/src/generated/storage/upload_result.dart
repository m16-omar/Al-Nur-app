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

import 'package:serverpod/serverpod.dart' as _i1;

abstract class StorageUploadResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  StorageUploadResult._({
    required this.success,
    required this.path,
    this.url,
    this.fileSize,
    this.mimeType,
    this.error,
  });

  factory StorageUploadResult({
    required bool success,
    required String path,
    String? url,
    int? fileSize,
    String? mimeType,
    String? error,
  }) = _StorageUploadResultImpl;

  factory StorageUploadResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return StorageUploadResult(
      success: _i1.BoolJsonExtension.fromJson(jsonSerialization['success']),
      path: jsonSerialization['path'] as String,
      url: jsonSerialization['url'] as String?,
      fileSize: jsonSerialization['fileSize'] as int?,
      mimeType: jsonSerialization['mimeType'] as String?,
      error: jsonSerialization['error'] as String?,
    );
  }

  bool success;

  String path;

  String? url;

  int? fileSize;

  String? mimeType;

  String? error;

  /// Returns a shallow copy of this [StorageUploadResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StorageUploadResult copyWith({
    bool? success,
    String? path,
    String? url,
    int? fileSize,
    String? mimeType,
    String? error,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StorageUploadResult',
      'success': success,
      'path': path,
      if (url != null) 'url': url,
      if (fileSize != null) 'fileSize': fileSize,
      if (mimeType != null) 'mimeType': mimeType,
      if (error != null) 'error': error,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StorageUploadResult',
      'success': success,
      'path': path,
      if (url != null) 'url': url,
      if (fileSize != null) 'fileSize': fileSize,
      if (mimeType != null) 'mimeType': mimeType,
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StorageUploadResultImpl extends StorageUploadResult {
  _StorageUploadResultImpl({
    required bool success,
    required String path,
    String? url,
    int? fileSize,
    String? mimeType,
    String? error,
  }) : super._(
         success: success,
         path: path,
         url: url,
         fileSize: fileSize,
         mimeType: mimeType,
         error: error,
       );

  /// Returns a shallow copy of this [StorageUploadResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StorageUploadResult copyWith({
    bool? success,
    String? path,
    Object? url = _Undefined,
    Object? fileSize = _Undefined,
    Object? mimeType = _Undefined,
    Object? error = _Undefined,
  }) {
    return StorageUploadResult(
      success: success ?? this.success,
      path: path ?? this.path,
      url: url is String? ? url : this.url,
      fileSize: fileSize is int? ? fileSize : this.fileSize,
      mimeType: mimeType is String? ? mimeType : this.mimeType,
      error: error is String? ? error : this.error,
    );
  }
}
