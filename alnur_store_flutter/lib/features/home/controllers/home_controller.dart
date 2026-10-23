import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/product_model.dart';

class HomeState {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final List<ProductModel> featuredProducts;
  final List<ProductModel> abayasProducts;
  final List<ProductModel> hijabsProducts;
  final List<ProductModel> jalabiasProducts;
  final List<ProductModel> thobesProducts;
  final int cartCount;
  final bool hasUnreadNotifications;
  final String searchQuery;
  final bool isLoading;

  const HomeState({
    required this.categories,
    this.selectedCategoryId,
    required this.featuredProducts,
    required this.abayasProducts,
    required this.hijabsProducts,
    required this.jalabiasProducts,
    required this.thobesProducts,
    this.cartCount = 3,
    this.hasUnreadNotifications = true,
    this.searchQuery = '',
    this.isLoading = false,
  });

  HomeState copyWith({
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    List<ProductModel>? featuredProducts,
    List<ProductModel>? abayasProducts,
    List<ProductModel>? hijabsProducts,
    List<ProductModel>? jalabiasProducts,
    List<ProductModel>? thobesProducts,
    int? cartCount,
    bool? hasUnreadNotifications,
    String? searchQuery,
    bool? isLoading,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      abayasProducts: abayasProducts ?? this.abayasProducts,
      hijabsProducts: hijabsProducts ?? this.hijabsProducts,
      jalabiasProducts: jalabiasProducts ?? this.jalabiasProducts,
      thobesProducts: thobesProducts ?? this.thobesProducts,
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
        id: 'jalabias',
        name: 'Jalabias',
        fallbackIcon: Icons.auto_awesome_outlined,
        backgroundColor: Color(0xFFFBF4E6),
      ),
      CategoryModel(
        id: 'thobes',
        name: 'Thobes',
        fallbackIcon: Icons.person_rounded,
        backgroundColor: Color(0xFFE9F0FA),
      ),
      CategoryModel(
        id: 'khimars',
        name: 'Khimars',
        fallbackIcon: Icons.face_3_rounded,
        backgroundColor: Color(0xFFF5EDF9),
      ),
      CategoryModel(
        id: 'prayer',
        name: 'Prayer Sets',
        fallbackIcon: Icons.mosque_outlined,
        backgroundColor: Color(0xFFE7F3EE),
      ),
      CategoryModel(
        id: 'jilbabs',
        name: 'Jilbabs',
        fallbackIcon: Icons.checkroom_rounded,
        backgroundColor: Color(0xFFF9EAE1),
      ),
    ],
    featuredProducts: const [
      ProductModel(
        id: 'feat_1',
        name: 'Dubai Gold Noir Abaya',
        price: 28500,
        originalPrice: 35000,
        rating: 4.9,
        reviewCount: 142,
        imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=500&q=80',
        categoryId: 'abayas',
        isFavorite: true,
        description: 'Hand-tailored Dubai crepe abaya featuring intricate golden wrist embroidery and graceful flowing drape.',
      ),
      ProductModel(
        id: 'feat_2',
        name: 'Pure Medina Silk Hijab',
        price: 8500,
        originalPrice: 11000,
        rating: 4.8,
        reviewCount: 96,
        imageUrl: 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=500&q=80',
        categoryId: 'hijabs',
        isFavorite: false,
        description: 'Ultra-soft, opaque Medina silk hijab with subtle luster, breathable for all-day comfort.',
      ),
      ProductModel(
        id: 'feat_3',
        name: 'Moroccan Royal Jalabia',
        price: 36000,
        originalPrice: 42000,
        rating: 4.9,
        reviewCount: 68,
        imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=500&q=80',
        categoryId: 'jalabias',
        isFavorite: true,
        description: 'Exquisite Moroccan Sfifa embroidery on premium emerald velvet with handmade sfifa buttons.',
      ),
      ProductModel(
        id: 'feat_4',
        name: 'Emirati Minimalist Thobe',
        price: 26000,
        originalPrice: 32000,
        rating: 4.8,
        reviewCount: 57,
        imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=500&q=80',
        categoryId: 'thobes',
        isFavorite: false,
        description: 'Crisp white cotton thobe with round collar, tailored for daily prayer, Friday Jumuah, and formal events.',
      ),
    ],
    abayasProducts: const [
      ProductModel(
        id: 'abaya_1',
        name: 'Classic Black Korean Abaya',
        price: 24500,
        originalPrice: 29000,
        rating: 4.8,
        reviewCount: 118,
        imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=500&q=80',
        categoryId: 'abayas',
        isFavorite: false,
        description: 'Made from high-grade Korean Nida fabric, offering lightweight modest coverage with deep black finish.',
      ),
      ProductModel(
        id: 'abaya_2',
        name: 'Pearl Beaded Organza Abaya',
        price: 38000,
        originalPrice: 45000,
        rating: 4.9,
        reviewCount: 82,
        imageUrl: 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?auto=format&fit=crop&w=500&q=80',
        categoryId: 'abayas',
        isFavorite: true,
        description: 'Luxurious double-layer organza abaya with hand-set river pearls along the lapel and cuffs.',
      ),
      ProductModel(
        id: 'abaya_3',
        name: 'Kimono Flare Linen Abaya',
        price: 27500,
        originalPrice: 32000,
        rating: 4.7,
        reviewCount: 64,
        imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80',
        categoryId: 'abayas',
        isFavorite: false,
        description: 'Breathable European linen blend in neutral sand, tailored with wide relaxed kimono sleeves.',
      ),
      ProductModel(
        id: 'abaya_4',
        name: 'Velvet Trim Midnight Abaya',
        price: 42000,
        originalPrice: 50000,
        rating: 4.9,
        reviewCount: 73,
        imageUrl: 'https://images.unsplash.com/photo-1617922001439-4a2e6562f328?auto=format&fit=crop&w=500&q=80',
        categoryId: 'abayas',
        isFavorite: false,
        description: 'Midnight blue weighted crepe lined with premium velvet accents for evening occasions.',
      ),
    ],
    hijabsProducts: const [
      ProductModel(
        id: 'hijab_1',
        name: 'Premium Modal Chiffon Hijab',
        price: 6500,
        originalPrice: 8000,
        rating: 4.8,
        reviewCount: 205,
        imageUrl: 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=500&q=80',
        categoryId: 'hijabs',
        isFavorite: true,
        description: 'Featherlight modal chiffon offering superior drape without slipping, in muted earth tones.',
      ),
      ProductModel(
        id: 'hijab_2',
        name: 'Crinkle Silk Crepe Hijab',
        price: 7200,
        originalPrice: 9000,
        rating: 4.7,
        reviewCount: 132,
        imageUrl: 'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?auto=format&fit=crop&w=500&q=80',
        categoryId: 'hijabs',
        isFavorite: false,
        description: 'Textured crinkle silk crepe that holds securely all day without requiring pins.',
      ),
      ProductModel(
        id: 'hijab_3',
        name: 'Sage Emerald Medina Hijab',
        price: 8800,
        originalPrice: 10500,
        rating: 4.9,
        reviewCount: 94,
        imageUrl: 'https://images.unsplash.com/photo-1596704017254-9b121068fb31?auto=format&fit=crop&w=500&q=80',
        categoryId: 'hijabs',
        isFavorite: false,
        description: 'Lustrous emerald green Medina silk hijab crafted for formal and festive celebrations.',
      ),
      ProductModel(
        id: 'hijab_4',
        name: 'Pleated Rose Crepe Hijab',
        price: 6800,
        originalPrice: 8500,
        rating: 4.7,
        reviewCount: 54,
        imageUrl: 'https://images.unsplash.com/photo-1574169208507-84376144848b?auto=format&fit=crop&w=500&q=80',
        categoryId: 'hijabs',
        isFavorite: false,
        description: 'Delicate accordion pleated chiffon crepe in dusty rose, effortless non-iron styling.',
      ),
    ],
    jalabiasProducts: const [
      ProductModel(
        id: 'jalabia_1',
        name: 'Gold Embellished Eid Jalabia',
        price: 45000,
        originalPrice: 52000,
        rating: 4.9,
        reviewCount: 89,
        imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=500&q=80',
        categoryId: 'jalabias',
        isFavorite: true,
        description: 'Festive floor-length jalabia adorned with golden zardozi embroidery and tasseled sash.',
      ),
      ProductModel(
        id: 'jalabia_2',
        name: 'Moroccan Kaftan Jalabia',
        price: 34000,
        originalPrice: 40000,
        rating: 4.8,
        reviewCount: 67,
        imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=500&q=80',
        categoryId: 'jalabias',
        isFavorite: false,
        description: 'Handcrafted Moroccan jalabia with braided cord neckline and wide bell sleeves.',
      ),
      ProductModel(
        id: 'jalabia_3',
        name: 'Embroidered Silk Crepe Jalabia',
        price: 31500,
        originalPrice: 38000,
        rating: 4.7,
        reviewCount: 53,
        imageUrl: 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=500&q=80',
        categoryId: 'jalabias',
        isFavorite: false,
        description: 'Pure silk crepe in ivory and bronze, tailored with side slits and hidden side pockets.',
      ),
      ProductModel(
        id: 'jalabia_4',
        name: 'Royal Sapphire Velvet Jalabia',
        price: 48000,
        originalPrice: 58000,
        rating: 4.9,
        reviewCount: 42,
        imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=500&q=80',
        categoryId: 'jalabias',
        isFavorite: true,
        description: 'Plush sapphire velvet jalabia with artisanal threadwork, tailored for grand receptions.',
      ),
    ],
    thobesProducts: const [
      ProductModel(
        id: 'thobe_1',
        name: 'Emirati Minimalist White Thobe',
        price: 26000,
        originalPrice: 32000,
        rating: 4.8,
        reviewCount: 57,
        imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=500&q=80',
        categoryId: 'thobes',
        isFavorite: false,
        description: 'Crisp white cotton thobe with round collar, tailored for daily prayer, Friday Jumuah, and formal events.',
      ),
      ProductModel(
        id: 'thobe_2',
        name: 'Saudi Gold Collar Jubbah',
        price: 34000,
        originalPrice: 40000,
        rating: 4.9,
        reviewCount: 48,
        imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=500&q=80',
        categoryId: 'thobes',
        isFavorite: true,
        description: 'Tailored luxury Jubbah with subtle gold embroidery on Mandarin collar and french cuff detailing.',
      ),
      ProductModel(
        id: 'thobe_3',
        name: 'Omani Tassel Royal Thobe',
        price: 29500,
        originalPrice: 35000,
        rating: 4.7,
        reviewCount: 39,
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=500&q=80',
        categoryId: 'thobes',
        isFavorite: false,
        description: 'Authentic Omani thobe with signature handcrafted chest tassel and breathable cotton-linen weave.',
      ),
      ProductModel(
        id: 'thobe_4',
        name: 'Moroccan Wool Blend Djellaba',
        price: 42000,
        originalPrice: 49000,
        rating: 4.9,
        reviewCount: 34,
        imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=500&q=80',
        categoryId: 'thobes',
        isFavorite: false,
        description: 'Traditional hooded Moroccan djellaba crafted with warm wool-blend fabric for winter prayer gatherings.',
      ),
    ],
  );

  @override
  HomeState build() {
    Future.microtask(() => fetchHomeDataFromBackend());
    return _initialState;
  }

  /// Fetches real-time collections and products from the Serverpod backend
  Future<void> fetchHomeDataFromBackend() async {
    state = state.copyWith(isLoading: true);
    try {
      final serverCategories = await client.category.getCategories();
      final serverProducts = await client.product.getProducts();

      // Ensure only genuine Islamic modest attire categories are processed
      final modestServerCategories = serverCategories.where((c) {
        final id = c.categoryId.toLowerCase();
        return id != 'perfumes' && id != 'jewelries' && id != 'bags' && id != 'slippers';
      }).toList();

      final modestServerProducts = serverProducts.where((p) {
        final id = p.categoryId.toLowerCase();
        return id != 'perfumes' && id != 'jewelries';
      }).toList();

      List<CategoryModel> mappedCategories = [];
      if (modestServerCategories.isNotEmpty) {
        mappedCategories = modestServerCategories.map((c) {
          return CategoryModel(
            id: c.categoryId,
            name: c.name,
            fallbackIcon: _getCategoryIcon(c.categoryId),
            backgroundColor: _parseColor(c.colorHex),
          );
        }).toList();
      }

      List<ProductModel> allMappedProducts = [];
      if (modestServerProducts.isNotEmpty) {
        allMappedProducts = modestServerProducts.map((p) {
          return ProductModel(
            id: p.id?.toString() ?? p.slug,
            name: p.name,
            price: p.price,
            originalPrice: p.originalPrice,
            rating: p.rating,
            reviewCount: p.reviewCount,
            imageUrl: p.imageUrl,
            categoryId: p.categoryId,
            description: p.description,
            isFavorite: p.isFavorite ?? false,
          );
        }).toList();
      }

      if (allMappedProducts.isNotEmpty) {
        final abayas = allMappedProducts.where((p) => p.categoryId == 'abayas').toList();
        final hijabs = allMappedProducts.where((p) => p.categoryId == 'hijabs').toList();
        final jalabias = allMappedProducts.where((p) => p.categoryId == 'jalabias').toList();
        final thobes = allMappedProducts.where((p) => p.categoryId == 'thobes').toList();
        final featured = allMappedProducts.where((p) => p.rating >= 4.8 || p.isFavorite).toList();

        state = state.copyWith(
          categories: mappedCategories.isNotEmpty ? mappedCategories : state.categories,
          featuredProducts: featured.isNotEmpty ? featured : state.featuredProducts,
          abayasProducts: abayas.isNotEmpty ? abayas : state.abayasProducts,
          hijabsProducts: hijabs.isNotEmpty ? hijabs : state.hijabsProducts,
          jalabiasProducts: jalabias.isNotEmpty ? jalabias : state.jalabiasProducts,
          thobesProducts: thobes.isNotEmpty ? thobes : state.thobesProducts,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('[HomeController] Serverpod backend sync notice: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Pull-to-refresh handler
  Future<void> refreshHomeData() async {
    await fetchHomeDataFromBackend();
  }

  static IconData _getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'abayas':
        return Icons.dry_cleaning_rounded;
      case 'hijabs':
        return Icons.all_inclusive_rounded;
      case 'jalabias':
        return Icons.auto_awesome_outlined;
      case 'thobes':
        return Icons.person_rounded;
      case 'khimars':
        return Icons.face_3_rounded;
      case 'prayer':
        return Icons.mosque_outlined;
      case 'jilbabs':
        return Icons.checkroom_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }

  static Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFFF5EFE6);
    try {
      final buffer = StringBuffer();
      if (hexString.startsWith('0x') || hexString.startsWith('0X')) {
        buffer.write(hexString.substring(2));
      } else if (hexString.startsWith('#')) {
        buffer.write(hexString.substring(1));
      } else {
        buffer.write(hexString);
      }
      if (buffer.length == 6) buffer.write('FF');
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFFF5EFE6);
    }
  }

  void selectCategory(CategoryModel category) {
    if (state.selectedCategoryId == category.id) {
      state = state.copyWith(selectedCategoryId: null);
    } else {
      state = state.copyWith(selectedCategoryId: category.id);
    }
  }

  void toggleFavorite(ProductModel product) {
    List<ProductModel> updateList(List<ProductModel> list) {
      return list.map((p) {
        if (p.id == product.id) {
          return p.copyWith(isFavorite: !p.isFavorite);
        }
        return p;
      }).toList();
    }

    state = state.copyWith(
      featuredProducts: updateList(state.featuredProducts),
      abayasProducts: updateList(state.abayasProducts),
      hijabsProducts: updateList(state.hijabsProducts),
      jalabiasProducts: updateList(state.jalabiasProducts),
      thobesProducts: updateList(state.thobesProducts),
    );

    // Asynchronously sync favorite status to Serverpod backend
    final intId = int.tryParse(product.id);
    if (intId != null) {
      try {
        client.product.toggleFavorite(intId);
      } catch (_) {}
    }
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
