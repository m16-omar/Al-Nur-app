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

abstract class StoreOrder implements _i1.SerializableModel {
  StoreOrder._({
    this.id,
    required this.orderRef,
    required this.customerEmail,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.totalAmount,
    required this.paymentStatus,
    required this.fulfillmentStatus,
    this.idempotencyKey,
    this.paymentReference,
    required this.itemsJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreOrder({
    int? id,
    required String orderRef,
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required double totalAmount,
    required String paymentStatus,
    required String fulfillmentStatus,
    String? idempotencyKey,
    String? paymentReference,
    required String itemsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StoreOrderImpl;

  factory StoreOrder.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoreOrder(
      id: jsonSerialization['id'] as int?,
      orderRef: jsonSerialization['orderRef'] as String,
      customerEmail: jsonSerialization['customerEmail'] as String,
      customerName: jsonSerialization['customerName'] as String,
      customerPhone: jsonSerialization['customerPhone'] as String,
      shippingAddress: jsonSerialization['shippingAddress'] as String,
      totalAmount: (jsonSerialization['totalAmount'] as num).toDouble(),
      paymentStatus: jsonSerialization['paymentStatus'] as String,
      fulfillmentStatus: jsonSerialization['fulfillmentStatus'] as String,
      idempotencyKey: jsonSerialization['idempotencyKey'] as String?,
      paymentReference: jsonSerialization['paymentReference'] as String?,
      itemsJson: jsonSerialization['itemsJson'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String orderRef;

  String customerEmail;

  String customerName;

  String customerPhone;

  String shippingAddress;

  double totalAmount;

  String paymentStatus;

  String fulfillmentStatus;

  String? idempotencyKey;

  String? paymentReference;

  String itemsJson;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [StoreOrder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StoreOrder copyWith({
    int? id,
    String? orderRef,
    String? customerEmail,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    double? totalAmount,
    String? paymentStatus,
    String? fulfillmentStatus,
    String? idempotencyKey,
    String? paymentReference,
    String? itemsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoreOrder',
      if (id != null) 'id': id,
      'orderRef': orderRef,
      'customerEmail': customerEmail,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'fulfillmentStatus': fulfillmentStatus,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      if (paymentReference != null) 'paymentReference': paymentReference,
      'itemsJson': itemsJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoreOrderImpl extends StoreOrder {
  _StoreOrderImpl({
    int? id,
    required String orderRef,
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required double totalAmount,
    required String paymentStatus,
    required String fulfillmentStatus,
    String? idempotencyKey,
    String? paymentReference,
    required String itemsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         orderRef: orderRef,
         customerEmail: customerEmail,
         customerName: customerName,
         customerPhone: customerPhone,
         shippingAddress: shippingAddress,
         totalAmount: totalAmount,
         paymentStatus: paymentStatus,
         fulfillmentStatus: fulfillmentStatus,
         idempotencyKey: idempotencyKey,
         paymentReference: paymentReference,
         itemsJson: itemsJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [StoreOrder]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StoreOrder copyWith({
    Object? id = _Undefined,
    String? orderRef,
    String? customerEmail,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    double? totalAmount,
    String? paymentStatus,
    String? fulfillmentStatus,
    Object? idempotencyKey = _Undefined,
    Object? paymentReference = _Undefined,
    String? itemsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreOrder(
      id: id is int? ? id : this.id,
      orderRef: orderRef ?? this.orderRef,
      customerEmail: customerEmail ?? this.customerEmail,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      fulfillmentStatus: fulfillmentStatus ?? this.fulfillmentStatus,
      idempotencyKey: idempotencyKey is String?
          ? idempotencyKey
          : this.idempotencyKey,
      paymentReference: paymentReference is String?
          ? paymentReference
          : this.paymentReference,
      itemsJson: itemsJson ?? this.itemsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
