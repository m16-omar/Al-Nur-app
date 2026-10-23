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
import 'ai/ai_stylist.dart' as _i2;
import 'categories/store_category.dart' as _i3;
import 'greetings/greeting.dart' as _i4;
import 'products/store_product.dart' as _i5;
import 'package:alnur_store_client/src/protocol/categories/store_category.dart'
    as _i6;
import 'package:alnur_store_client/src/protocol/products/store_product.dart'
    as _i7;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i8;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i9;
export 'ai/ai_stylist.dart';
export 'categories/store_category.dart';
export 'greetings/greeting.dart';
export 'products/store_product.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.AiStylistResponse) {
      return _i2.AiStylistResponse.fromJson(data) as T;
    }
    if (t == _i3.StoreCategory) {
      return _i3.StoreCategory.fromJson(data) as T;
    }
    if (t == _i4.Greeting) {
      return _i4.Greeting.fromJson(data) as T;
    }
    if (t == _i5.StoreProduct) {
      return _i5.StoreProduct.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AiStylistResponse?>()) {
      return (data != null ? _i2.AiStylistResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.StoreCategory?>()) {
      return (data != null ? _i3.StoreCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Greeting?>()) {
      return (data != null ? _i4.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.StoreProduct?>()) {
      return (data != null ? _i5.StoreProduct.fromJson(data) : null) as T;
    }
    if (t == List<_i5.StoreProduct>) {
      return (data as List)
              .map((e) => deserialize<_i5.StoreProduct>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i5.StoreProduct>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i5.StoreProduct>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i6.StoreCategory>) {
      return (data as List)
              .map((e) => deserialize<_i6.StoreCategory>(e))
              .toList()
          as T;
    }
    if (t == List<_i7.StoreProduct>) {
      return (data as List)
              .map((e) => deserialize<_i7.StoreProduct>(e))
              .toList()
          as T;
    }
    try {
      return _i8.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i9.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AiStylistResponse => 'AiStylistResponse',
      _i3.StoreCategory => 'StoreCategory',
      _i4.Greeting => 'Greeting',
      _i5.StoreProduct => 'StoreProduct',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('alnur_store.', '');
    }

    switch (data) {
      case _i2.AiStylistResponse():
        return 'AiStylistResponse';
      case _i3.StoreCategory():
        return 'StoreCategory';
      case _i4.Greeting():
        return 'Greeting';
      case _i5.StoreProduct():
        return 'StoreProduct';
    }
    className = _i8.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i9.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AiStylistResponse') {
      return deserialize<_i2.AiStylistResponse>(data['data']);
    }
    if (dataClassName == 'StoreCategory') {
      return deserialize<_i3.StoreCategory>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i4.Greeting>(data['data']);
    }
    if (dataClassName == 'StoreProduct') {
      return deserialize<_i5.StoreProduct>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i8.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i9.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i8.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i9.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
