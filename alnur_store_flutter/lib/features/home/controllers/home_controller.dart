import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/product_model.dart';

class HomeState {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final List<ProductModel> featuredProducts;
  final List<ProductModel> perfumesProducts;
  final List<ProductModel> weddingRingsProducts;
  final List<ProductModel> wristwatchesProducts;
  final List<ProductModel> necklacesProducts;
  final List<ProductModel> banglesProducts;
  final List<ProductModel> jewelriesProducts;
  final List<ProductModel> ringsProducts;
  final int cartCount;
  final bool hasUnreadNotifications;
  final String searchQuery;
  final bool isLoading;

  const HomeState({
    required this.categories,
    this.selectedCategoryId,
    required this.featuredProducts,
    required this.perfumesProducts,
    required this.weddingRingsProducts,
    required this.wristwatchesProducts,
    this.necklacesProducts = const [],
    this.banglesProducts = const [],
    required this.jewelriesProducts,
    required this.ringsProducts,
    this.cartCount = 3,
    this.hasUnreadNotifications = true,
    this.searchQuery = '',
    this.isLoading = false,
  });

  // Backward-compatibility getters for legacy tests & components
  List<ProductModel> get abayasProducts => perfumesProducts;
  List<ProductModel> get hijabsProducts => weddingRingsProducts;
  List<ProductModel> get jalabiasProducts => wristwatchesProducts;
  List<ProductModel> get thobesProducts => jewelriesProducts;

  List<ProductModel> get allProducts {
    final map = <String, ProductModel>{};
    for (final p in [
      ...featuredProducts,
      ...perfumesProducts,
      ...weddingRingsProducts,
      ...wristwatchesProducts,
      ...necklacesProducts,
      ...banglesProducts,
      ...jewelriesProducts,
      ...ringsProducts,
    ]) {
      final key = p.name.trim().toLowerCase();
      // Deduplicate by name, preserving favorite status if any instance is favorited
      if (!map.containsKey(key)) {
        map[key] = p;
      } else if (p.isFavorite && !map[key]!.isFavorite) {
        map[key] = p;
      }
    }
    return map.values.toList();
  }

  List<ProductModel> get favoriteProducts {
    return allProducts.where((p) => p.isFavorite).toList();
  }

  List<ProductModel> get filteredSearchResults {
    if (searchQuery.trim().isEmpty) return [];
    final q = searchQuery.toLowerCase().trim();
    return allProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.categoryId.toLowerCase().contains(q);
    }).toList();
  }

  HomeState copyWith({
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    bool clearCategory = false,
    List<ProductModel>? featuredProducts,
    List<ProductModel>? perfumesProducts,
    List<ProductModel>? weddingRingsProducts,
    List<ProductModel>? wristwatchesProducts,
    List<ProductModel>? necklacesProducts,
    List<ProductModel>? banglesProducts,
    List<ProductModel>? jewelriesProducts,
    List<ProductModel>? ringsProducts,
    // Support legacy parameters for compatibility
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
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      featuredProducts: featuredProducts ?? this.featuredProducts,
      perfumesProducts: perfumesProducts ?? abayasProducts ?? this.perfumesProducts,
      weddingRingsProducts: weddingRingsProducts ?? hijabsProducts ?? this.weddingRingsProducts,
      wristwatchesProducts: wristwatchesProducts ?? jalabiasProducts ?? this.wristwatchesProducts,
      necklacesProducts: necklacesProducts ?? this.necklacesProducts,
      banglesProducts: banglesProducts ?? this.banglesProducts,
      jewelriesProducts: jewelriesProducts ?? thobesProducts ?? this.jewelriesProducts,
      ringsProducts: ringsProducts ?? this.ringsProducts,
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
        id: 'perfumes',
        name: 'Perfumes & Oud',
        fallbackIcon: Icons.spa_rounded,
        backgroundColor: Color(0xFFF5EDF9),
      ),
      CategoryModel(
        id: 'wedding-rings',
        name: 'Wedding Rings',
        fallbackIcon: Icons.diamond_rounded,
        backgroundColor: Color(0xFFFDF7E7),
      ),
      CategoryModel(
        id: 'wristwatches',
        name: 'Wristwatches',
        fallbackIcon: Icons.watch_outlined,
        backgroundColor: Color(0xFFE9F0FA),
      ),
      CategoryModel(
        id: 'necklaces',
        name: 'Luxury Necklaces',
        fallbackIcon: Icons.diamond_outlined,
        backgroundColor: Color(0xFFF3E8FF),
      ),
      CategoryModel(
        id: 'bangles',
        name: 'Royal Bangles',
        fallbackIcon: Icons.circle_outlined,
        backgroundColor: Color(0xFFFEF3C7),
      ),
      CategoryModel(
        id: 'jewelries',
        name: 'Fine Jewelry',
        fallbackIcon: Icons.auto_awesome_rounded,
        backgroundColor: Color(0xFFF9EAE1),
      ),
      CategoryModel(
        id: 'rings',
        name: 'Rings',
        fallbackIcon: Icons.circle_outlined,
        backgroundColor: Color(0xFFE8F1EC),
      ),
    ],
    featuredProducts: const [
      ProductModel(
        id: 'feat_1',
        name: 'Royal Amber & Cambodian Oud EDP (100ml)',
        price: 28500,
        originalPrice: 35000,
        rating: 5.0,
        reviewCount: 148,
        imageUrl: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=600&q=80',
        categoryId: 'perfumes',
        isFavorite: true,
        description: 'Opulent Cambodian oud infused with warm amber, Madagascar vanilla, and long-lasting sillage for Nigerian weddings and Jumu\'ah celebrations.',
      ),
      ProductModel(
        id: 'feat_2',
        name: 'Eternal Vows 18K Gold Plated Couple Wedding Bands',
        price: 68000,
        originalPrice: 85000,
        rating: 5.0,
        reviewCount: 136,
        imageUrl: 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wedding-rings',
        isFavorite: true,
        description: 'His & Hers matching Nigerian marital rings finished in non-tarnish 18K brushed gold with curved comfort fit and luxury presentation case.',
      ),
      ProductModel(
        id: 'feat_3',
        name: 'Geneva Diamond-Bezel Emerald Rose Gold Watch',
        price: 36000,
        originalPrice: 45000,
        rating: 4.9,
        reviewCount: 124,
        imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wristwatches',
        isFavorite: true,
        description: 'Striking emerald green sunburst dial encircled with Austrian crystal accents and an 18K rose-gold Jubilee link bracelet.',
      ),
      ProductModel(
        id: 'feat_4',
        name: 'Zainab Luxury Bridal Choker & Earrings Set',
        price: 75000,
        originalPrice: 95000,
        rating: 5.0,
        reviewCount: 140,
        imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80',
        categoryId: 'jewelries',
        isFavorite: true,
        description: 'High-grade Austrian crystal choker necklace with chandelier drop earrings, handcrafted for Nigerian traditional and white wedding receptions.',
      ),
    ],
    perfumesProducts: const [
      ProductModel(
        id: 'perfume_1',
        name: 'Royal Amber & Cambodian Oud EDP (100ml)',
        price: 28500,
        originalPrice: 35000,
        rating: 5.0,
        reviewCount: 148,
        imageUrl: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=600&q=80',
        categoryId: 'perfumes',
        isFavorite: true,
        description: 'Opulent Cambodian oud infused with warm amber, Madagascar vanilla, and long-lasting sillage for Nigerian weddings and celebrations.',
      ),
      ProductModel(
        id: 'perfume_2',
        name: 'Pure Musk Tahara & White Lotus Oil (12ml)',
        price: 14000,
        originalPrice: 18000,
        rating: 4.9,
        reviewCount: 112,
        imageUrl: 'https://images.unsplash.com/photo-1547887537-6158d64c35b3?auto=format&fit=crop&w=600&q=80',
        categoryId: 'perfumes',
        isFavorite: false,
        description: 'Concentrated alcohol-free white musk oil with powdery lotus floral accents, revered across Nigeria for modesty and everyday freshness.',
      ),
      ProductModel(
        id: 'perfume_3',
        name: 'Lattafa Khamrah & Smoky Bukhoor Set',
        price: 38000,
        originalPrice: 45000,
        rating: 4.9,
        reviewCount: 94,
        imageUrl: 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=600&q=80',
        categoryId: 'perfumes',
        isFavorite: true,
        description: 'Decadent blend of sweet dates, cinnamon bark, roasted praline, and smoky incense wood. An esteemed Nigerian bridal gift.',
      ),
      ProductModel(
        id: 'perfume_4',
        name: 'Golden Damask Rose & Vanilla Arabian Extrait',
        price: 24000,
        originalPrice: 30000,
        rating: 4.8,
        reviewCount: 86,
        imageUrl: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=600&q=80',
        categoryId: 'perfumes',
        isFavorite: false,
        description: 'Exotic damask rose petals steeped in caramelized vanilla pods and amberwood, tailored for warm tropical Nigerian evenings.',
      ),
    ],
    weddingRingsProducts: const [
      ProductModel(
        id: 'wring_1',
        name: 'Eternal Vows 18K Gold Plated Couple Wedding Bands',
        price: 68000,
        originalPrice: 85000,
        rating: 5.0,
        reviewCount: 136,
        imageUrl: 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wedding-rings',
        isFavorite: true,
        description: 'His & Hers matching Nigerian marital rings finished in non-tarnish 18K brushed gold with curved comfort fit and luxury presentation case.',
      ),
      ProductModel(
        id: 'wring_2',
        name: 'Zirconia Solitaire Halo Engagement Ring (925 Silver)',
        price: 38500,
        originalPrice: 48000,
        rating: 4.9,
        reviewCount: 92,
        imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wedding-rings',
        isFavorite: true,
        description: 'Dazzling 2-carat round brilliant cubic zirconia stone bordered by a pavé halo on solid rhodium-plated sterling silver.',
      ),
      ProductModel(
        id: 'wring_3',
        name: 'Crown Tiara Diamond-Simulant Wedding Band',
        price: 32000,
        originalPrice: 40000,
        rating: 4.8,
        reviewCount: 64,
        imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wedding-rings',
        isFavorite: false,
        description: 'Regal tiara contour ring encrusted with micro-pavé crystals, designed to stack seamlessly with engagement rings or wear standalone.',
      ),
      ProductModel(
        id: 'wring_4',
        name: 'Dubai 18K Solid Gold-Bonded Marital Bands (Pair)',
        price: 85000,
        originalPrice: 105000,
        rating: 5.0,
        reviewCount: 78,
        imageUrl: 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wedding-rings',
        isFavorite: true,
        description: 'Heavyweight classic dome wedding bands crafted with multi-layer 18K gold bonded core, guaranteed resistant to sweat, perfume, and daily wear.',
      ),
    ],
    wristwatchesProducts: const [
      ProductModel(
        id: 'watch_1',
        name: 'Geneva Diamond-Bezel Emerald Rose Gold Watch',
        price: 36000,
        originalPrice: 45000,
        rating: 4.9,
        reviewCount: 124,
        imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wristwatches',
        isFavorite: true,
        description: 'Striking emerald green sunburst dial encircled with Austrian crystal accents and an 18K rose-gold Jubilee link bracelet.',
      ),
      ProductModel(
        id: 'watch_2',
        name: 'Naviforce Royal Roman Numeral Men\'s Timepiece',
        price: 32500,
        originalPrice: 40000,
        rating: 4.8,
        reviewCount: 108,
        imageUrl: 'https://images.unsplash.com/photo-1533139502658-0198f920d8e8?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wristwatches',
        isFavorite: false,
        description: 'Water-resistant midnight blue dial featuring gold roman numerals, date calendar window, and hardened mineral scratch-resistant glass.',
      ),
      ProductModel(
        id: 'watch_3',
        name: 'Hannah Martin Minimalist Mesh Strap Women\'s Watch',
        price: 22000,
        originalPrice: 28000,
        rating: 4.7,
        reviewCount: 88,
        imageUrl: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wristwatches',
        isFavorite: false,
        description: 'Ultra-slim 7mm profile watch with breathable Milanese magnetic mesh strap, beloved by Nigerian corporate professionals and brides.',
      ),
      ProductModel(
        id: 'watch_4',
        name: 'Al-Nur Dual His & Hers Luxury Watch Gift Set',
        price: 58000,
        originalPrice: 72000,
        rating: 5.0,
        reviewCount: 95,
        imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80',
        categoryId: 'wristwatches',
        isFavorite: true,
        description: 'Matching couple timepieces with Japanese quartz movement and dual-tone gold links, packaged in an embossed velvet gift chest.',
      ),
    ],
    necklacesProducts: const [
      ProductModel(
        id: 'neck_1',
        name: 'Dubai 18K Gold Multi-Layer Figaro Chain Necklace',
        price: 32000,
        originalPrice: 40000,
        rating: 4.9,
        reviewCount: 118,
        imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80',
        categoryId: 'necklaces',
        isFavorite: true,
        description: 'Triple-layered Figaro chain with 18K vacuum plating. Guaranteed sweat and perfume resistant for Nigerian weddings and parties.',
      ),
      ProductModel(
        id: 'neck_2',
        name: 'Zainab Bridal Austrian Crystal Choker Set',
        price: 75000,
        originalPrice: 95000,
        rating: 5.0,
        reviewCount: 142,
        imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80',
        categoryId: 'necklaces',
        isFavorite: true,
        description: 'Regal Austrian crystal choker necklace with cascading drop crystals, designed for Nigerian brides, traditional weddings, and gala nights.',
      ),
      ProductModel(
        id: 'neck_3',
        name: '18K Gold-Layered Heavyweight Dubai Rope Chain (5mm)',
        price: 26000,
        originalPrice: 34000,
        rating: 4.8,
        reviewCount: 115,
        imageUrl: 'https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?auto=format&fit=crop&w=600&q=80',
        categoryId: 'necklaces',
        isFavorite: false,
        description: 'Heavyweight 5mm twisted rope chain with secure lobster claw clasp. Triple-plated for non-tarnish luster under Nigerian humidity.',
      ),
      ProductModel(
        id: 'neck_4',
        name: 'Arabic "Sabr & Shukr" Coin Medallion Necklace',
        price: 22500,
        originalPrice: 28000,
        rating: 4.9,
        reviewCount: 96,
        imageUrl: 'https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?auto=format&fit=crop&w=600&q=80',
        categoryId: 'necklaces',
        isFavorite: false,
        description: 'Reversible double-sided coin pendant engraved with Arabic Patience (Sabr) and Gratitude (Shukr), on an adjustable 18-inch curb chain.',
      ),
    ],
    banglesProducts: const [
      ProductModel(
        id: 'bangle_1',
        name: 'Kano Royal Filigree 18K Gold Bangle Set (Pair)',
        price: 42000,
        originalPrice: 52000,
        rating: 5.0,
        reviewCount: 128,
        imageUrl: 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=600&q=80',
        categoryId: 'bangles',
        isFavorite: true,
        description: 'Intricately embossed Northern Nigerian and Arabian filigree motifs on polished gold-tone brass with hidden spring hinges.',
      ),
      ProductModel(
        id: 'bangle_2',
        name: 'Sparkling 4mm Zirconia Tennis Bracelet (White Gold Finish)',
        price: 28000,
        originalPrice: 36000,
        rating: 4.9,
        reviewCount: 104,
        imageUrl: 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=600&q=80',
        categoryId: 'bangles',
        isFavorite: true,
        description: 'Continuous line of four-prong hand-set brilliant round stones with double safety latch. An enduring luxury staple for every wrist.',
      ),
      ProductModel(
        id: 'bangle_3',
        name: 'Dubai Intricate Lattice Open-Cuff Gold Bangle',
        price: 35000,
        originalPrice: 44000,
        rating: 4.8,
        reviewCount: 79,
        imageUrl: 'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?auto=format&fit=crop&w=600&q=80',
        categoryId: 'bangles',
        isFavorite: false,
        description: 'Wide architectural lattice open cuff bangle with micro-beaded borders. Fits all wrist sizes with flexible tension adjustment.',
      ),
      ProductModel(
        id: 'bangle_4',
        name: 'Stackable Twisted Gold Wire Bangles (Set of 3)',
        price: 38000,
        originalPrice: 46000,
        rating: 4.9,
        reviewCount: 88,
        imageUrl: 'https://images.unsplash.com/photo-1602751584552-8ba73aad10e1?auto=format&fit=crop&w=600&q=80',
        categoryId: 'bangles',
        isFavorite: false,
        description: 'Trio of high-shine diamond-cut and twisted gold wire bangles designed to jingle gracefully with traditional Nigerian attire.',
      ),
    ],
    jewelriesProducts: const [
      ProductModel(
        id: 'jewel_1',
        name: 'Grand Imperial Dubai 4-Piece Bridal Jewelry Set',
        price: 125000,
        originalPrice: 155000,
        rating: 5.0,
        reviewCount: 89,
        imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80',
        categoryId: 'jewelries',
        isFavorite: true,
        description: 'Complete majestic set comprising necklace, chandelier earrings, statement ring, and matching bangle for grand Nigerian celebrations.',
      ),
      ProductModel(
        id: 'jewel_2',
        name: 'Royal Emerald Crystal Teardrop Gala Jewelry Set',
        price: 68000,
        originalPrice: 85000,
        rating: 4.9,
        reviewCount: 92,
        imageUrl: 'https://images.unsplash.com/photo-1535632787350-4e68ef0ac584?auto=format&fit=crop&w=600&q=80',
        categoryId: 'jewelries',
        isFavorite: false,
        description: 'Lush deep emerald teardrop crystals surrounded by halo pavé stones on gold-plated collar necklace with matching earrings.',
      ),
      ProductModel(
        id: 'jewel_3',
        name: 'Traditional Arewa Gold Filigree Brooch & Earring Set',
        price: 34000,
        originalPrice: 42000,
        rating: 4.8,
        reviewCount: 67,
        imageUrl: 'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?auto=format&fit=crop&w=600&q=80',
        categoryId: 'jewelries',
        isFavorite: false,
        description: 'Northern Nigerian inspired geometric filigree brooch pin and clip earrings, an aristocratic addition to lace and headties.',
      ),
      ProductModel(
        id: 'jewel_4',
        name: 'Pearl & 18K Gold Bead Layered Owambe Statement Set',
        price: 48000,
        originalPrice: 60000,
        rating: 4.9,
        reviewCount: 110,
        imageUrl: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80',
        categoryId: 'jewelries',
        isFavorite: true,
        description: 'Lustrous faux baroque pearls interspersed with textured 18K gold beads. Crafted for mother-of-the-day and dignitaries.',
      ),
    ],
    ringsProducts: const [
      ProductModel(
        id: 'ring_1',
        name: 'Emerald Cut Green Crystal Statement Ring',
        price: 18500,
        originalPrice: 24000,
        rating: 4.9,
        reviewCount: 116,
        imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
        categoryId: 'rings',
        isFavorite: true,
        description: 'Vibrant faceted emerald-green centerpiece stone set on an 18K gold-plated band, capturing magnificent light from every angle.',
      ),
      ProductModel(
        id: 'ring_2',
        name: 'Arabic Calligraphy \'Barakah\' Open Band Ring',
        price: 16000,
        originalPrice: 20000,
        rating: 4.8,
        reviewCount: 94,
        imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
        categoryId: 'rings',
        isFavorite: false,
        description: 'Adjustable 925 sterling silver band engraved with the Arabic prayer for blessing (Barakah), accented with micro-pave zirconia.',
      ),
      ProductModel(
        id: 'ring_3',
        name: 'Classic 3-Row Pavé Crystal Eternity Band',
        price: 15000,
        originalPrice: 19000,
        rating: 4.7,
        reviewCount: 84,
        imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=600&q=80',
        categoryId: 'rings',
        isFavorite: false,
        description: 'Triple row of shimmering hand-set cubic zirconia crystals. Perfect for everyday luxury, ring stacking, or vow renewal.',
      ),
      ProductModel(
        id: 'ring_4',
        name: 'Vintage Black Onyx Signet Ring',
        price: 19500,
        originalPrice: 25000,
        rating: 4.9,
        reviewCount: 76,
        imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
        categoryId: 'rings',
        isFavorite: true,
        description: 'Bold octagonal natural black onyx gemstone encased in heavy gold-tone bezel, favored by both men and women for distinctive elegance.',
      ),
    ],
  );

  bool _isDisposed = false;

  @override
  HomeState build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
    });
    Future.microtask(() => fetchHomeDataFromBackend());
    return _initialState;
  }

  /// Fetches real-time collections and products from the Serverpod backend
  Future<void> fetchHomeDataFromBackend() async {
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true);
    try {
      final serverCategories = await client.category.getCategories();
      final serverProducts = await client.product.getProducts();

      if (_isDisposed) return;

      List<CategoryModel> mappedCategories = [];
      if (serverCategories.isNotEmpty) {
        mappedCategories = serverCategories.map((c) {
          return CategoryModel(
            id: c.categoryId,
            name: c.name,
            fallbackIcon: _getCategoryIcon(c.categoryId),
            backgroundColor: _parseColor(c.colorHex),
          );
        }).toList();
      }

      List<ProductModel> allMappedProducts = [];
      if (serverProducts.isNotEmpty) {
        allMappedProducts = serverProducts.map((p) {
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
        final perfumes = allMappedProducts.where((p) => p.categoryId == 'perfumes').toList();
        final weddingRings = allMappedProducts.where((p) => p.categoryId == 'wedding-rings').toList();
        final watches = allMappedProducts.where((p) => p.categoryId == 'wristwatches').toList();
        final necklaces = allMappedProducts.where((p) => p.categoryId == 'necklaces').toList();
        final bangles = allMappedProducts.where((p) => p.categoryId == 'bangles').toList();
        final jewelries = allMappedProducts.where((p) => p.categoryId == 'jewelries').toList();
        final rings = allMappedProducts.where((p) => p.categoryId == 'rings').toList();
        final featured = allMappedProducts.where((p) => p.rating >= 4.9 || p.isFavorite).toList();

        if (_isDisposed) return;
        state = state.copyWith(
          categories: mappedCategories.isNotEmpty ? mappedCategories : state.categories,
          featuredProducts: featured.isNotEmpty ? featured : state.featuredProducts,
          perfumesProducts: perfumes.isNotEmpty ? perfumes : state.perfumesProducts,
          weddingRingsProducts: weddingRings.isNotEmpty ? weddingRings : state.weddingRingsProducts,
          wristwatchesProducts: watches.isNotEmpty ? watches : state.wristwatchesProducts,
          necklacesProducts: necklaces.isNotEmpty ? necklaces : state.necklacesProducts,
          banglesProducts: bangles.isNotEmpty ? bangles : state.banglesProducts,
          jewelriesProducts: jewelries.isNotEmpty ? jewelries : state.jewelriesProducts,
          ringsProducts: rings.isNotEmpty ? rings : state.ringsProducts,
          isLoading: false,
        );
      } else {
        if (!_isDisposed) state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('[HomeController] Serverpod backend sync notice: $e');
      if (!_isDisposed) state = state.copyWith(isLoading: false);
    }
  }

  /// Pull-to-refresh handler
  Future<void> refreshHomeData() async {
    await fetchHomeDataFromBackend();
  }

  static IconData _getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'perfumes':
        return Icons.spa_rounded;
      case 'wedding-rings':
        return Icons.diamond_rounded;
      case 'wristwatches':
        return Icons.watch_outlined;
      case 'necklaces':
        return Icons.diamond_outlined;
      case 'bangles':
        return Icons.circle_outlined;
      case 'jewelries':
        return Icons.auto_awesome_rounded;
      case 'rings':
        return Icons.circle_outlined;
      default:
        return Icons.auto_awesome_rounded;
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
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: category.id);
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void toggleFavorite(ProductModel product) {
    final updatedFavorites = !product.isFavorite;
    final targetName = product.name.trim().toLowerCase();

    List<ProductModel> updateList(List<ProductModel> list) {
      return list.map((p) {
        if (p.id == product.id || p.name.trim().toLowerCase() == targetName) {
          return p.copyWith(isFavorite: updatedFavorites);
        }
        return p;
      }).toList();
    }

    state = state.copyWith(
      featuredProducts: updateList(state.featuredProducts),
      perfumesProducts: updateList(state.perfumesProducts),
      weddingRingsProducts: updateList(state.weddingRingsProducts),
      wristwatchesProducts: updateList(state.wristwatchesProducts),
      necklacesProducts: updateList(state.necklacesProducts),
      banglesProducts: updateList(state.banglesProducts),
      jewelriesProducts: updateList(state.jewelriesProducts),
      ringsProducts: updateList(state.ringsProducts),
    );

    final id = int.tryParse(product.id);
    if (id != null) {
      client.product.toggleFavorite(id).catchError((e) {
        debugPrint('[HomeController] Failed to toggle favorite on backend: $e');
        return null;
      });
    }
  }

  void removeFavorite(ProductModel product) {
    final targetName = product.name.trim().toLowerCase();

    List<ProductModel> updateList(List<ProductModel> list) {
      return list.map((p) {
        if (p.id == product.id || p.name.trim().toLowerCase() == targetName) {
          return p.copyWith(isFavorite: false);
        }
        return p;
      }).toList();
    }

    state = state.copyWith(
      featuredProducts: updateList(state.featuredProducts),
      perfumesProducts: updateList(state.perfumesProducts),
      weddingRingsProducts: updateList(state.weddingRingsProducts),
      wristwatchesProducts: updateList(state.wristwatchesProducts),
      necklacesProducts: updateList(state.necklacesProducts),
      banglesProducts: updateList(state.banglesProducts),
      jewelriesProducts: updateList(state.jewelriesProducts),
      ringsProducts: updateList(state.ringsProducts),
    );

    final id = int.tryParse(product.id);
    if (id != null) {
      client.product.toggleFavorite(id).catchError((e) {
        debugPrint('[HomeController] Failed to toggle favorite on backend: $e');
        return null;
      });
    }
  }
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(HomeController.new);
