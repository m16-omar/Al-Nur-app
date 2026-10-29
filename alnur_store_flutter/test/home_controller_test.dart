import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alnur_store_flutter/features/home/controllers/home_controller.dart';
import 'package:alnur_store_client/alnur_store_client.dart';
import 'package:alnur_store_flutter/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeController Unit Tests', () {
    late ProviderContainer container;

    setUpAll(() {
      try {
        client = Client('https://alnur-store.api.serverpod.space');
      } catch (_) {}
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state contains categories, collections and products', () {
      final state = container.read(homeControllerProvider);

      expect(state.categories, isNotEmpty);
      expect(state.featuredProducts, isNotEmpty);
      expect(state.abayasProducts, isNotEmpty);
      expect(state.hijabsProducts, isNotEmpty);
      expect(state.jalabiasProducts, isNotEmpty);
      expect(state.thobesProducts, isNotEmpty);
      expect(state.allProducts, isNotEmpty);
    });

    test('Selecting a category updates selectedCategoryId and toggles off on repeat', () {
      final controller = container.read(homeControllerProvider.notifier);
      final initialCategory = container.read(homeControllerProvider).categories.first;

      controller.selectCategory(initialCategory);
      expect(container.read(homeControllerProvider).selectedCategoryId, equals(initialCategory.id));

      // Tap again to deselect
      controller.selectCategory(initialCategory);
      expect(container.read(homeControllerProvider).selectedCategoryId, isNull);
    });

    test('Toggling favorite updates isFavorite and favoriteProducts list', () {
      final controller = container.read(homeControllerProvider.notifier);
      final product = container.read(homeControllerProvider).featuredProducts.first;
      final initialFavorite = product.isFavorite;

      controller.toggleFavorite(product);
      final updatedState = container.read(homeControllerProvider);
      final updatedProduct = updatedState.featuredProducts.firstWhere((p) => p.id == product.id);

      expect(updatedProduct.isFavorite, equals(!initialFavorite));
      if (!initialFavorite) {
        expect(updatedState.favoriteProducts.any((p) => p.id == product.id), isTrue);
      }
    });

    test('Search query filters allProducts correctly', () {
      final controller = container.read(homeControllerProvider.notifier);

      controller.updateSearchQuery('abaya');
      final searchState = container.read(homeControllerProvider);

      expect(searchState.searchQuery, equals('abaya'));
      expect(searchState.filteredSearchResults, isNotEmpty);
      for (final p in searchState.filteredSearchResults) {
        final matches = p.name.toLowerCase().contains('abaya') ||
            p.description.toLowerCase().contains('abaya') ||
            p.categoryId.toLowerCase().contains('abaya');
        expect(matches, isTrue);
      }
    });
  });
}
