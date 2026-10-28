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

abstract class UserAccountInfo implements _i1.SerializableModel {
  UserAccountInfo._({
    this.id,
    required this.userEmail,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.preferredCurrency,
    this.bio,
  });

  factory UserAccountInfo({
    int? id,
    required String userEmail,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? preferredCurrency,
    String? bio,
  }) = _UserAccountInfoImpl;

  factory UserAccountInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserAccountInfo(
      id: jsonSerialization['id'] as int?,
      userEmail: jsonSerialization['userEmail'] as String,
      fullName: jsonSerialization['fullName'] as String,
      phoneNumber: jsonSerialization['phoneNumber'] as String?,
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      preferredCurrency: jsonSerialization['preferredCurrency'] as String?,
      bio: jsonSerialization['bio'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userEmail;

  String fullName;

  String? phoneNumber;

  String? avatarUrl;

  String? preferredCurrency;

  String? bio;

  /// Returns a shallow copy of this [UserAccountInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserAccountInfo copyWith({
    int? id,
    String? userEmail,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? preferredCurrency,
    String? bio,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserAccountInfo',
      if (id != null) 'id': id,
      'userEmail': userEmail,
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
      if (bio != null) 'bio': bio,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserAccountInfoImpl extends UserAccountInfo {
  _UserAccountInfoImpl({
    int? id,
    required String userEmail,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? preferredCurrency,
    String? bio,
  }) : super._(
         id: id,
         userEmail: userEmail,
         fullName: fullName,
         phoneNumber: phoneNumber,
         avatarUrl: avatarUrl,
         preferredCurrency: preferredCurrency,
         bio: bio,
       );

  /// Returns a shallow copy of this [UserAccountInfo]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserAccountInfo copyWith({
    Object? id = _Undefined,
    String? userEmail,
    String? fullName,
    Object? phoneNumber = _Undefined,
    Object? avatarUrl = _Undefined,
    Object? preferredCurrency = _Undefined,
    Object? bio = _Undefined,
  }) {
    return UserAccountInfo(
      id: id is int? ? id : this.id,
      userEmail: userEmail ?? this.userEmail,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber is String? ? phoneNumber : this.phoneNumber,
      avatarUrl: avatarUrl is String? ? avatarUrl : this.avatarUrl,
      preferredCurrency: preferredCurrency is String?
          ? preferredCurrency
          : this.preferredCurrency,
      bio: bio is String? ? bio : this.bio,
    );
  }
}
