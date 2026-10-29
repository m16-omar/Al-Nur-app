import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alnur_store_flutter/features/cart/controllers/cart_controller.dart';
import 'package:alnur_store_flutter/shared/models/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CartController Unit Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial cart state calculations', () {
      final state = container.read(cartControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.appliedPromoCode, equals('ALNUR15'));
      expect(state.discountPercent, equals(0.15));
    });

    test('Adding a product to cart updates count and subtotal', () async {
      final controller = container.read(cartControllerProvider.notifier);

      const testProduct = ProductModel(
        id: 'test_abaya_1',
        name: 'Luxury Velvet Abaya',
        price: 35000,
        rating: 4.9,
        reviewCount: 20,
        imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b',
        categoryId: 'abayas',
      );

      await controller.addItem(testProduct, size: '56', color: 'Midnight Black');

      final state = container.read(cartControllerProvider);
      expect(state.items.any((item) => item.productId == 'test_abaya_1'), isTrue);
      expect(state.totalCount, greaterThan(0));
      expect(state.subtotal, greaterThanOrEqualTo(35000));
    });

    test('Updating quantity recalculates subtotal and grandTotal', () async {
      final controller = container.read(cartControllerProvider.notifier);

      const testProduct = ProductModel(
        id: 'test_hijab_1',
        name: 'Medina Silk Hijab',
        price: 10000,
        rating: 4.8,
        reviewCount: 15,
        imageUrl: 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167',
        categoryId: 'hijabs',
      );

      await controller.addItem(testProduct, size: 'Standard', color: 'Emerald');
      final stateWithOne = container.read(cartControllerProvider);
      final item = stateWithOne.items.firstWhere((i) => i.productId == 'test_hijab_1');
      final initialQty = item.quantity;

      // updateQuantity takes a delta (e.g. +1 to increment)
      await controller.updateQuantity(item.id, 1);
      final stateWithIncrement = container.read(cartControllerProvider);
      final updatedItem = stateWithIncrement.items.firstWhere((i) => i.id == item.id);

      expect(updatedItem.quantity, equals(initialQty + 1));
      expect(stateWithIncrement.subtotal, greaterThan(stateWithOne.subtotal));
    });

    test('Clearing cart removes all items and resets grandTotal to 0', () async {
      final controller = container.read(cartControllerProvider.notifier);

      const testProduct = ProductModel(
        id: 'test_item_clear',
        name: 'Moroccan Jalabia',
        price: 25000,
        rating: 5.0,
        reviewCount: 10,
        imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b',
        categoryId: 'jalabias',
      );

      await controller.addItem(testProduct);
      expect(container.read(cartControllerProvider).items.isNotEmpty, isTrue);

      await controller.clearCart();
      final clearedState = container.read(cartControllerProvider);
      expect(clearedState.items, isEmpty);
      expect(clearedState.totalCount, equals(0));
      expect(clearedState.grandTotal, equals(0.0));
    });
  });
}
