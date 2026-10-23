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

abstract class StoreCategory implements _i1.SerializableModel {
  StoreCategory._({
    this.id,
    required this.categoryId,
    required this.name,
    this.iconName,
    this.tagline,
    this.intro,
    this.colorHex,
  });

  factory StoreCategory({
    int? id,
    required String categoryId,
    required String name,
    String? iconName,
    String? tagline,
    String? intro,
    String? colorHex,
  }) = _StoreCategoryImpl;

  factory StoreCategory.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoreCategory(
      id: jsonSerialization['id'] as int?,
      categoryId: jsonSerialization['categoryId'] as String,
      name: jsonSerialization['name'] as String,
      iconName: jsonSerialization['iconName'] as String?,
      tagline: jsonSerialization['tagline'] as String?,
      intro: jsonSerialization['intro'] as String?,
      colorHex: jsonSerialization['colorHex'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String categoryId;

  String name;

  String? iconName;

  String? tagline;

  String? intro;

  String? colorHex;

  /// Returns a shallow copy of this [StoreCategory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StoreCategory copyWith({
    int? id,
    String? categoryId,
    String? name,
    String? iconName,
    String? tagline,
    String? intro,
    String? colorHex,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoreCategory',
      if (id != null) 'id': id,
      'categoryId': categoryId,
      'name': name,
      if (iconName != null) 'iconName': iconName,
      if (tagline != null) 'tagline': tagline,
      if (intro != null) 'intro': intro,
      if (colorHex != null) 'colorHex': colorHex,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoreCategoryImpl extends StoreCategory {
  _StoreCategoryImpl({
    int? id,
    required String categoryId,
    required String name,
    String? iconName,
    String? tagline,
    String? intro,
    String? colorHex,
  }) : super._(
         id: id,
         categoryId: categoryId,
         name: name,
         iconName: iconName,
         tagline: tagline,
         intro: intro,
         colorHex: colorHex,
       );

  /// Returns a shallow copy of this [StoreCategory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StoreCategory copyWith({
    Object? id = _Undefined,
    String? categoryId,
    String? name,
    Object? iconName = _Undefined,
    Object? tagline = _Undefined,
    Object? intro = _Undefined,
    Object? colorHex = _Undefined,
  }) {
    return StoreCategory(
      id: id is int? ? id : this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      iconName: iconName is String? ? iconName : this.iconName,
      tagline: tagline is String? ? tagline : this.tagline,
      intro: intro is String? ? intro : this.intro,
      colorHex: colorHex is String? ? colorHex : this.colorHex,
    );
  }
}
