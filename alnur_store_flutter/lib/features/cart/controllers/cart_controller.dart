import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/product_model.dart';
import '../models/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;
  final String? appliedPromoCode;
  final double discountPercent;
  final double shippingFee;
  final bool isLoading;

  const CartState({
    this.items = const [],
    this.appliedPromoCode = 'ALNUR15',
    this.discountPercent = 0.15,
    this.shippingFee = 2500.0,
    this.isLoading = false,
  });

  int get totalCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get discountAmount {
    if (appliedPromoCode == null || discountPercent <= 0) return 0.0;
    return subtotal * discountPercent;
  }

  double get grandTotal {
    if (items.isEmpty) return 0.0;
    return subtotal - discountAmount + shippingFee;
  }

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItemModel>? items,
    String? appliedPromoCode,
    double? discountPercent,
    double? shippingFee,
    bool? isLoading,
    bool clearPromo = false,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedPromoCode: clearPromo ? null : (appliedPromoCode ?? this.appliedPromoCode),
      discountPercent: clearPromo ? 0.0 : (discountPercent ?? this.discountPercent),
      shippingFee: shippingFee ?? this.shippingFee,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CartController extends Notifier<CartState> {
  static const String _keyCartItems = 'alnur_persisted_cart_items_v2';
  static const String _keyPromoCode = 'alnur_persisted_promo_code';

  @override
  CartState build() {
    _loadFromStorage();
    return const CartState();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_keyCartItems);
      final savedPromo = prefs.getString(_keyPromoCode) ?? 'ALNUR15';

      if (itemsJson != null && itemsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(itemsJson);
        final loadedItems = decoded.map((e) => CartItemModel.fromMap(e as Map<String, dynamic>)).toList();
        state = state.copyWith(
          items: loadedItems,
          appliedPromoCode: savedPromo.isNotEmpty ? savedPromo : null,
          discountPercent: savedPromo.isNotEmpty ? 0.15 : 0.0,
        );
      } else {
        // Initial modest items for demo shopping bag
        final initialItems = [
          const CartItemModel(
            id: 'cart_1',
            productId: 'feat_1',
            name: 'Dubai Gold Noir Abaya',
            categoryId: 'abayas',
            price: 28500,
            imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=500&q=80',
            size: '56',
            color: 'Midnight Black / Gold',
            quantity: 1,
          ),
          const CartItemModel(
            id: 'cart_2',
            productId: 'hijab_1',
            name: 'Pure Medina Silk Hijab',
            categoryId: 'hijabs',
            price: 8500,
            imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=500&q=80',
            size: 'Standard (180x75cm)',
            color: 'Emerald Silk',
            quantity: 2,
          ),
          const CartItemModel(
            id: 'cart_3',
            productId: 'jalabia_1',
            name: 'Royal Emerald Velvet Jalabia',
            categoryId: 'jalabias',
            price: 32000,
            imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=500&q=80',
            size: '58',
            color: 'Deep Emerald / Gold',
            quantity: 1,
          ),
        ];
        state = state.copyWith(items: initialItems);
        await _saveToStorage(initialItems);
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage(List<CartItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(items.map((e) => e.toMap()).toList());
      await prefs.setString(_keyCartItems, encoded);
    } catch (_) {}
  }

  /// Adds a product to the cart with chosen size & color, saving state locally
  Future<void> addItem(
    ProductModel product, {
    String size = 'Standard (56)',
    String color = 'Default',
    int quantity = 1,
  }) async {
    final existingIndex = state.items.indexWhere(
      (item) => item.productId == product.id && item.size == size && item.color == color,
    );

    List<CartItemModel> updatedItems;
    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updated = existing.copyWith(quantity: existing.quantity + quantity);
      updatedItems = List<CartItemModel>.from(state.items);
      updatedItems[existingIndex] = updated;
    } else {
      final newItem = CartItemModel(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}_${product.id}',
        productId: product.id,
        name: product.name,
        categoryId: product.categoryId,
        price: product.price,
        imageUrl: product.imageUrl,
        size: size,
        color: color,
        quantity: quantity,
      );
      updatedItems = [...state.items, newItem];
    }

    state = state.copyWith(items: updatedItems);
    await _saveToStorage(updatedItems);
  }

  /// Increments or decrements item quantity
  Future<void> updateQuantity(String cartItemId, int delta) async {
    final updatedList = <CartItemModel>[];
    for (final item in state.items) {
      if (item.id == cartItemId) {
        final newQty = item.quantity + delta;
        if (newQty > 0) {
          updatedList.add(item.copyWith(quantity: newQty));
        }
      } else {
        updatedList.add(item);
      }
    }

    state = state.copyWith(items: updatedList);
    await _saveToStorage(updatedList);
  }

  /// Removes an item completely from the cart
  Future<void> removeItem(String cartItemId) async {
    final updatedList = state.items.where((item) => item.id != cartItemId).toList();
    state = state.copyWith(items: updatedList);
    await _saveToStorage(updatedList);
  }

  /// Toggles or applies a promo code (e.g. 'ALNUR15')
  Future<void> togglePromoCode(String code) async {
    final clean = code.trim().toUpperCase();
    if (state.appliedPromoCode != null) {
      state = state.copyWith(clearPromo: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPromoCode);
    } else {
      if (clean == 'ALNUR15' || clean == 'JUMUAH15') {
        state = state.copyWith(appliedPromoCode: clean, discountPercent: 0.15);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyPromoCode, clean);
      }
    }
  }

  /// Clears all cart items upon successful checkout
  Future<void> clearCart() async {
    state = state.copyWith(items: const []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCartItems);
  }
}

final cartControllerProvider =
    NotifierProvider<CartController, CartState>(CartController.new);
