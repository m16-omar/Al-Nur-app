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

abstract class UserAddress implements _i1.SerializableModel {
  UserAddress._({
    this.id,
    required this.userEmail,
    required this.title,
    required this.recipientName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.city,
    required this.state,
    this.country,
    this.postalCode,
    required this.isDefault,
    this.additionalInstructions,
  });

  factory UserAddress({
    int? id,
    required String userEmail,
    required String title,
    required String recipientName,
    required String phoneNumber,
    required String streetAddress,
    required String city,
    required String state,
    String? country,
    String? postalCode,
    required bool isDefault,
    String? additionalInstructions,
  }) = _UserAddressImpl;

  factory UserAddress.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserAddress(
      id: jsonSerialization['id'] as int?,
      userEmail: jsonSerialization['userEmail'] as String,
      title: jsonSerialization['title'] as String,
      recipientName: jsonSerialization['recipientName'] as String,
      phoneNumber: jsonSerialization['phoneNumber'] as String,
      streetAddress: jsonSerialization['streetAddress'] as String,
      city: jsonSerialization['city'] as String,
      state: jsonSerialization['state'] as String,
      country: jsonSerialization['country'] as String?,
      postalCode: jsonSerialization['postalCode'] as String?,
      isDefault: _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      additionalInstructions:
          jsonSerialization['additionalInstructions'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userEmail;

  String title;

  String recipientName;

  String phoneNumber;

  String streetAddress;

  String city;

  String state;

  String? country;

  String? postalCode;

  bool isDefault;

  String? additionalInstructions;

  /// Returns a shallow copy of this [UserAddress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserAddress copyWith({
    int? id,
    String? userEmail,
    String? title,
    String? recipientName,
    String? phoneNumber,
    String? streetAddress,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
    String? additionalInstructions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserAddress',
      if (id != null) 'id': id,
      'userEmail': userEmail,
      'title': title,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      if (country != null) 'country': country,
      if (postalCode != null) 'postalCode': postalCode,
      'isDefault': isDefault,
      if (additionalInstructions != null)
        'additionalInstructions': additionalInstructions,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserAddressImpl extends UserAddress {
  _UserAddressImpl({
    int? id,
    required String userEmail,
    required String title,
    required String recipientName,
    required String phoneNumber,
    required String streetAddress,
    required String city,
    required String state,
    String? country,
    String? postalCode,
    required bool isDefault,
    String? additionalInstructions,
  }) : super._(
         id: id,
         userEmail: userEmail,
         title: title,
         recipientName: recipientName,
         phoneNumber: phoneNumber,
         streetAddress: streetAddress,
         city: city,
         state: state,
         country: country,
         postalCode: postalCode,
         isDefault: isDefault,
         additionalInstructions: additionalInstructions,
       );

  /// Returns a shallow copy of this [UserAddress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserAddress copyWith({
    Object? id = _Undefined,
    String? userEmail,
    String? title,
    String? recipientName,
    String? phoneNumber,
    String? streetAddress,
    String? city,
    String? state,
    Object? country = _Undefined,
    Object? postalCode = _Undefined,
    bool? isDefault,
    Object? additionalInstructions = _Undefined,
  }) {
    return UserAddress(
      id: id is int? ? id : this.id,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country is String? ? country : this.country,
      postalCode: postalCode is String? ? postalCode : this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      additionalInstructions: additionalInstructions is String?
          ? additionalInstructions
          : this.additionalInstructions,
    );
  }
}
