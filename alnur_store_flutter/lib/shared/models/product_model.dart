class ProductModel {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String categoryId;
  final bool isFavorite;
  final String description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.categoryId,
    this.isFavorite = false,
    this.description = '',
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? categoryId,
    bool? isFavorite,
    String? description,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
    );
  }
}
