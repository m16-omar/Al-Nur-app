import 'dart:convert';

class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final String categoryId;
  final double price;
  final String imageUrl;
  final String size;
  final String color;
  final int quantity;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.imageUrl,
    this.size = 'Standard',
    this.color = 'Classic',
    this.quantity = 1,
  });

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    String? categoryId,
    double? price,
    String? imageUrl,
    String? size,
    String? color,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'imageUrl': imageUrl,
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id']?.toString() ?? '',
      productId: map['productId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      size: map['size']?.toString() ?? 'Standard',
      color: map['color']?.toString() ?? 'Classic',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory CartItemModel.fromJson(String source) =>
      CartItemModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
