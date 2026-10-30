import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/product_model.dart';
import '../../authentication/controllers/auth_controller.dart';
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
  static const String _keyPromoCode = 'alnur_persisted_promo_code';
  bool _isDisposed = false;
  bool _hasUserModifiedState = false;
  String _cachedStorageKey = 'alnur_cart_guest';

  String _getStorageKey() {
    if (_isDisposed) return _cachedStorageKey;
    try {
      final authState = ref.read(authControllerProvider);
      final email = authState.user?.email.trim().toLowerCase();
      if (email != null && email.isNotEmpty && !authState.isGuest) {
        _cachedStorageKey = 'alnur_cart_user_$email';
        return _cachedStorageKey;
      }
    } catch (_) {}
    _cachedStorageKey = 'alnur_cart_guest';
    return _cachedStorageKey;
  }

  @override
  CartState build() {
    _isDisposed = false;
    _hasUserModifiedState = false;
    ref.onDispose(() {
      _isDisposed = true;
    });
    _getStorageKey();
    _loadFromStorage();
    return const CartState();
  }

  /// Reloads cart scoped strictly to the current active user
  Future<void> reloadCartForActiveUser() async {
    _hasUserModifiedState = false;
    _getStorageKey();
    await _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final storageKey = _cachedStorageKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      if (_hasUserModifiedState) return;

      final itemsJson = prefs.getString(storageKey);
      final savedPromo = prefs.getString(_keyPromoCode) ?? 'ALNUR15';

      if (itemsJson != null && itemsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(itemsJson);
        final loadedItems = decoded
            .map((e) => CartItemModel.fromMap(e as Map<String, dynamic>))
            .where((item) =>
                item.name != 'Dubai Gold Noir Abaya' &&
                item.name != 'Pure Medina Silk Hijab' &&
                item.name != 'Royal Emerald Velvet Jalabia')
            .toList();

        if (_isDisposed || _hasUserModifiedState) return;
        state = state.copyWith(
          items: loadedItems,
          appliedPromoCode: savedPromo.isNotEmpty ? savedPromo : null,
          discountPercent: savedPromo.isNotEmpty ? 0.15 : 0.0,
        );
        await _saveToStorage(loadedItems, storageKey);
      } else {
        if (!_isDisposed && !_hasUserModifiedState) {
          state = state.copyWith(items: const []);
        }
      }
    } catch (_) {
      if (!_isDisposed && !_hasUserModifiedState) {
        state = state.copyWith(items: const []);
      }
    }
  }

  Future<void> _saveToStorage(List<CartItemModel> items, [String? explicitKey]) async {
    if (_isDisposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      final storageKey = explicitKey ?? _getStorageKey();
      final encoded = json.encode(items.map((e) => e.toMap()).toList());
      await prefs.setString(storageKey, encoded);
    } catch (_) {}
  }

  /// Adds a product to the cart with chosen size & color, saving state locally
  Future<void> addItem(
    ProductModel product, {
    String size = 'Standard (56)',
    String color = 'Default',
    int quantity = 1,
  }) async {
    _hasUserModifiedState = true;
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
    _hasUserModifiedState = true;
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
    _hasUserModifiedState = true;
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

  /// Clears all cart items for the active user upon successful checkout
  Future<void> clearCart() async {
    _hasUserModifiedState = true;
    final storageKey = _cachedStorageKey;
    state = state.copyWith(items: const []);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (_) {}
  }
}

final cartControllerProvider =
    NotifierProvider<CartController, CartState>(CartController.new);
