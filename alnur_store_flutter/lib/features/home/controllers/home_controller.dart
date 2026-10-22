import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/product_model.dart';

class HomeState {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final List<ProductModel> featuredProducts;
  final int cartCount;
  final bool hasUnreadNotifications;
  final String searchQuery;
  final bool isLoading;

  const HomeState({
    required this.categories,
    this.selectedCategoryId,
    required this.featuredProducts,
    this.cartCount = 3,
    this.hasUnreadNotifications = true,
    this.searchQuery = '',
    this.isLoading = false,
  });

  HomeState copyWith({
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    List<ProductModel>? featuredProducts,
    int? cartCount,
    bool? hasUnreadNotifications,
    String? searchQuery,
    bool? isLoading,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      cartCount: cartCount ?? this.cartCount,
      hasUnreadNotifications: hasUnreadNotifications ?? this.hasUnreadNotifications,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeController extends Notifier<HomeState> {
  static final HomeState _initialState = HomeState(
    categories: const [
      CategoryModel(
        id: 'abayas',
        name: 'Abayas',
        fallbackIcon: Icons.dry_cleaning_rounded,
        backgroundColor: Color(0xFFF5EFE6),
      ),
      CategoryModel(
        id: 'hijabs',
        name: 'Hijabs',
        fallbackIcon: Icons.all_inclusive_rounded,
        backgroundColor: Color(0xFFE8F1EC),
      ),
      CategoryModel(
        id: 'dresses',
        name: 'Dresses',
        fallbackIcon: Icons.checkroom_rounded,
        backgroundColor: Color(0xFFF9EAE1),
      ),
      CategoryModel(
        id: 'shoes',
        name: 'Shoes',
        fallbackIcon: Icons.roller_skating_outlined,
        backgroundColor: Color(0xFFF3ECE2),
      ),
      CategoryModel(
        id: 'bags',
        name: 'Bags',
        fallbackIcon: Icons.shopping_bag_outlined,
        backgroundColor: Color(0xFFE5EDE8),
      ),
      CategoryModel(
        id: 'accessories',
        name: 'Accessories',
        fallbackIcon: Icons.watch_outlined,
        backgroundColor: Color(0xFFF6F0E4),
      ),
    ],
    featuredProducts: const [
      ProductModel(
        id: 'prod_1',
        name: 'Classic Black Abaya',
        price: 18500,
        originalPrice: 22000,
        rating: 4.8,
        reviewCount: 124,
        imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=400&q=80',
        categoryId: 'abayas',
        isFavorite: false,
        description: 'Made from premium Korean Nida fabric, featuring elegant sleeve embroidery and a flowing silhouette.',
      ),
      ProductModel(
        id: 'prod_2',
        name: 'Premium Chiffon Hijab',
        price: 7500,
        originalPrice: 9000,
        rating: 4.7,
        reviewCount: 98,
        imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=400&q=80',
        categoryId: 'hijabs',
        isFavorite: true,
        description: 'Lightweight, non-slip chiffon in rich muted tones, perfect for both everyday and formal wear.',
      ),
      ProductModel(
        id: 'prod_3',
        name: 'Modest Maxi Dress',
        price: 22000,
        originalPrice: 26000,
        rating: 4.6,
        reviewCount: 76,
        imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=400&q=80',
        categoryId: 'dresses',
        isFavorite: false,
        description: 'Full-length modest dress with belted waist, breathable fabric, and gentle pleated details.',
      ),
      ProductModel(
        id: 'prod_4',
        name: 'Comfort Sneakers',
        price: 15000,
        originalPrice: 18000,
        rating: 4.5,
        reviewCount: 62,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=400&q=80',
        categoryId: 'shoes',
        isFavorite: false,
        description: 'Ergonomic, lightweight sneakers crafted for all-day comfort with cushioned arch support.',
      ),
    ],
  );

  @override
  HomeState build() {
    return _initialState;
  }

  void selectCategory(CategoryModel category) {
    if (state.selectedCategoryId == category.id) {
      state = state.copyWith(selectedCategoryId: null);
    } else {
      state = state.copyWith(selectedCategoryId: category.id);
    }
  }

  void toggleFavorite(ProductModel product) {
    final updated = state.featuredProducts.map((p) {
      if (p.id == product.id) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
    state = state.copyWith(featuredProducts: updated);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void incrementCart() {
    state = state.copyWith(cartCount: state.cartCount + 1);
  }
}

final homeControllerProvider =
    NotifierProvider<HomeController, HomeState>(HomeController.new);
