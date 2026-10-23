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

abstract class StoreProduct implements _i1.SerializableModel {
  StoreProduct._({
    this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.isAvailable,
    this.isFavorite,
  });

  factory StoreProduct({
    int? id,
    required String name,
    required String slug,
    required String categoryId,
    required double price,
    double? originalPrice,
    required double rating,
    required int reviewCount,
    required String imageUrl,
    required String description,
    required bool isAvailable,
    bool? isFavorite,
  }) = _StoreProductImpl;

  factory StoreProduct.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoreProduct(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      slug: jsonSerialization['slug'] as String,
      categoryId: jsonSerialization['categoryId'] as String,
      price: (jsonSerialization['price'] as num).toDouble(),
      originalPrice: (jsonSerialization['originalPrice'] as num?)?.toDouble(),
      rating: (jsonSerialization['rating'] as num).toDouble(),
      reviewCount: jsonSerialization['reviewCount'] as int,
      imageUrl: jsonSerialization['imageUrl'] as String,
      description: jsonSerialization['description'] as String,
      isAvailable: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isAvailable'],
      ),
      isFavorite: jsonSerialization['isFavorite'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isFavorite']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  String slug;

  String categoryId;

  double price;

  double? originalPrice;

  double rating;

  int reviewCount;

  String imageUrl;

  String description;

  bool isAvailable;

  bool? isFavorite;

  /// Returns a shallow copy of this [StoreProduct]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StoreProduct copyWith({
    int? id,
    String? name,
    String? slug,
    String? categoryId,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? description,
    bool? isAvailable,
    bool? isFavorite,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoreProduct',
      if (id != null) 'id': id,
      'name': name,
      'slug': slug,
      'categoryId': categoryId,
      'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'description': description,
      'isAvailable': isAvailable,
      if (isFavorite != null) 'isFavorite': isFavorite,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoreProductImpl extends StoreProduct {
  _StoreProductImpl({
    int? id,
    required String name,
    required String slug,
    required String categoryId,
    required double price,
    double? originalPrice,
    required double rating,
    required int reviewCount,
    required String imageUrl,
    required String description,
    required bool isAvailable,
    bool? isFavorite,
  }) : super._(
         id: id,
         name: name,
         slug: slug,
         categoryId: categoryId,
         price: price,
         originalPrice: originalPrice,
         rating: rating,
         reviewCount: reviewCount,
         imageUrl: imageUrl,
         description: description,
         isAvailable: isAvailable,
         isFavorite: isFavorite,
       );

  /// Returns a shallow copy of this [StoreProduct]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StoreProduct copyWith({
    Object? id = _Undefined,
    String? name,
    String? slug,
    String? categoryId,
    double? price,
    Object? originalPrice = _Undefined,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? description,
    bool? isAvailable,
    Object? isFavorite = _Undefined,
  }) {
    return StoreProduct(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      originalPrice: originalPrice is double?
          ? originalPrice
          : this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite is bool? ? isFavorite : this.isFavorite,
    );
  }
}
