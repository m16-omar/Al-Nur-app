import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../idempotency/idempotency_manager.dart';

class ProductEndpoint extends Endpoint {
  /// Fetches products, filtering optionally by categoryId and search query.
  /// Automatically synchronizes official Nigerian luxury catalog (Rings, Perfumes, Jewelries, Wedding Rings, Wristwatches).
  Future<List<StoreProduct>> getProducts(
    Session session, {
    String? categoryId,
    String? search,
  }) async {
    final existing = await StoreProduct.db.find(session);
    final hasLegacy = existing.any((p) =>
        p.categoryId == 'abayas' ||
        p.categoryId == 'hijabs' ||
        p.categoryId == 'jalabias' ||
        p.categoryId == 'thobes' ||
        p.categoryId == 'silk-khimars');

    if (existing.isEmpty || hasLegacy) {
      if (hasLegacy) {
        for (final p in existing) {
          await StoreProduct.db.deleteRow(session, p);
        }
      }
      await _seedDefaultProducts(session);
    }

    return await StoreProduct.db.find(
      session,
      where: (t) {
        Expression? exp;
        if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
          exp = t.categoryId.equals(categoryId);
        }
        if (search != null && search.trim().isNotEmpty) {
          final queryExp = t.name.ilike('%${search.trim()}%') |
              t.description.ilike('%${search.trim()}%');
          exp = exp != null ? (exp & queryExp) : queryExp;
        }
        return exp ?? Constant.bool(true);
      },
      orderBy: (t) => t.id,
    );
  }

  /// Explicitly resets and reseeds the catalog with the 20 official Nigerian luxury products.
  Future<List<StoreProduct>> reseedProducts(Session session) async {
    final existing = await StoreProduct.db.find(session);
    for (final p in existing) {
      await StoreProduct.db.deleteRow(session, p);
    }
    await _seedDefaultProducts(session);
    return await StoreProduct.db.find(
      session,
      orderBy: (t) => t.id,
    );
  }

  /// Fetches a single product by its database ID.
  Future<StoreProduct?> getProductById(Session session, int id) async {
    return await StoreProduct.db.findById(session, id);
  }

  /// Toggles favorite status on a product.
  Future<StoreProduct?> toggleFavorite(Session session, int productId) async {
    final product = await StoreProduct.db.findById(session, productId);
    if (product == null) return null;

    final updated = product.copyWith(
      isFavorite: !(product.isFavorite ?? false),
    );
    return await StoreProduct.db.updateRow(session, updated);
  }

  /// Creates a new product in the store database with optional idempotency protection.
  Future<StoreProduct> createProduct(
    Session session,
    StoreProduct product, {
    String? idempotencyKey,
  }) async {
    return await IdempotencyManager.run<StoreProduct>(
      session: session,
      idempotencyKey: idempotencyKey,
      endpoint: 'product.createProduct',
      requestData: {
        'name': product.name,
        'slug': product.slug,
        'categoryId': product.categoryId,
        'price': product.price,
      },
      action: () async => await StoreProduct.db.insertRow(session, product),
      toJson: (p) => jsonEncode(p.toJson()),
      fromJson: (j) =>
          StoreProduct.fromJson(jsonDecode(j) as Map<String, dynamic>),
    );
  }

  /// Updates an existing product.
  Future<StoreProduct> updateProduct(
    Session session,
    StoreProduct product,
  ) async {
    return await StoreProduct.db.updateRow(session, product);
  }

  /// Deletes a product by ID.
  Future<bool> deleteProduct(Session session, int id) async {
    final product = await StoreProduct.db.findById(session, id);
    if (product == null) return false;
    await StoreProduct.db.deleteRow(session, product);
    return true;
  }

  Future<void> _seedDefaultProducts(Session session) async {
    final seedItems = [
      // 1. PERFUMES & ROYAL OUD
      StoreProduct(
        name: 'Royal Amber & Cambodian Oud EDP (100ml)',
        slug: 'royal-amber-cambodian-oud',
        categoryId: 'perfumes',
        price: 28500.0,
        originalPrice: 35000.0,
        rating: 5.0,
        reviewCount: 148,
        imageUrl:
            'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=600&q=80',
        description:
            'Opulent Cambodian oud infused with warm amber, Madagascar vanilla, and long-lasting sillage for Nigerian weddings and Jumu\'ah celebrations.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: 'Pure Musk Tahara & White Lotus Oil (12ml)',
        slug: 'pure-musk-tahara-lotus-oil',
        categoryId: 'perfumes',
        price: 14000.0,
        originalPrice: 18000.0,
        rating: 4.9,
        reviewCount: 112,
        imageUrl:
            'https://images.unsplash.com/photo-1547887537-6158d64c35b3?auto=format&fit=crop&w=600&q=80',
        description:
            'Concentrated alcohol-free white musk oil with powdery lotus floral accents, revered across Nigeria for personal elegance and daily freshness.',
        isAvailable: true,
        isFavorite: false,
      ),
      StoreProduct(
        name: 'Lattafa Khamrah & Smoky Bukhoor Set',
        slug: 'lattafa-khamrah-smoky-bukhoor',
        categoryId: 'perfumes',
        price: 38000.0,
        originalPrice: 45000.0,
        rating: 4.9,
        reviewCount: 94,
        imageUrl:
            'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=600&q=80',
        description:
            'Decadent blend of sweet dates, cinnamon bark, roasted praline, and smoky incense wood. An esteemed Nigerian bridal shower and anniversary gift.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: 'Golden Damask Rose & Vanilla Arabian Extrait',
        slug: 'golden-damask-rose-vanilla',
        categoryId: 'perfumes',
        price: 24000.0,
        originalPrice: 30000.0,
        rating: 4.8,
        reviewCount: 86,
        imageUrl:
            'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=600&q=80',
        description:
            'Exotic damask rose petals steeped in caramelized vanilla pods and amberwood, tailored for warm tropical Nigerian evenings.',
        isAvailable: true,
        isFavorite: false,
      ),

      // 2. WEDDING RINGS & BRIDAL BANDS
      StoreProduct(
        name: 'Eternal Vows 18K Gold Plated Couple Wedding Bands',
        slug: 'eternal-vows-18k-wedding-bands',
        categoryId: 'wedding-rings',
        price: 68000.0,
        originalPrice: 85000.0,
        rating: 5.0,
        reviewCount: 136,
        imageUrl:
            'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=600&q=80',
        description:
            'His & Hers matching Nigerian marital rings finished in non-tarnish 18K brushed gold with curved comfort fit and luxury presentation case.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: 'Zirconia Solitaire Halo Engagement Ring (925 Silver)',
        slug: 'zirconia-solitaire-halo-engagement-ring',
        categoryId: 'wedding-rings',
        price: 38500.0,
        originalPrice: 48000.0,
        rating: 4.9,
        reviewCount: 92,
        imageUrl:
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
        description:
            'Dazzling 2-carat round brilliant cubic zirconia stone bordered by a pavé halo on solid rhodium-plated sterling silver.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: 'Crown Tiara Diamond-Simulant Wedding Band',
        slug: 'crown-tiara-diamond-wedding-band',
        categoryId: 'wedding-rings',
        price: 32000.0,
        originalPrice: 40000.0,
        rating: 4.8,
        reviewCount: 64,
        imageUrl:
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=600&q=80',
        description:
            'Regal tiara contour ring encrusted with micro-pavé crystals, designed to stack seamlessly with engagement rings or wear standalone.',
        isAvailable: true,
        isFavorite: false,
      ),
      StoreProduct(
        name: 'Dubai 18K Solid Gold-Bonded Marital Bands (Pair)',
        slug: 'dubai-18k-gold-bonded-marital-bands',
        categoryId: 'wedding-rings',
        price: 85000.0,
        originalPrice: 105000.0,
        rating: 5.0,
        reviewCount: 78,
        imageUrl:
            'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=600&q=80',
        description:
            'Heavyweight classic dome wedding bands crafted with multi-layer 18K gold bonded core, guaranteed resistant to sweat, perfume, and daily wear.',
        isAvailable: true,
        isFavorite: true,
      ),

      // 3. WRISTWATCHES
      StoreProduct(
        name: 'Geneva Diamond-Bezel Emerald Rose Gold Watch',
        slug: 'geneva-diamond-bezel-emerald-watch',
        categoryId: 'wristwatches',
        price: 36000.0,
        originalPrice: 45000.0,
        rating: 4.9,
        reviewCount: 124,
        imageUrl:
            'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80',
        description:
            'Striking emerald green sunburst dial encircled with Austrian crystal accents and an 18K rose-gold Jubilee stainless steel link bracelet.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: 'Naviforce Royal Roman Numeral Men\'s Timepiece',
        slug: 'naviforce-royal-roman-mens-watch',
        categoryId: 'wristwatches',
        price: 32500.0,
        originalPrice: 40000.0,
        rating: 4.8,
        reviewCount: 108,
        imageUrl:
            'https://images.unsplash.com/photo-1533139502658-0198f920d8e8?auto=format&fit=crop&w=600&q=80',
        description:
            'Water-resistant midnight blue dial featuring gold roman numerals, date calendar window, and hardened mineral scratch-resistant glass.',
        isAvailable: true,
        isFavorite: false,
      ),
      StoreProduct(
        name: 'Hannah Martin Minimalist Mesh Strap Women\'s Watch',
        slug: 'hannah-martin-minimalist-mesh-watch',
        categoryId: 'wristwatches',
        price: 22000.0,
        originalPrice: 28000.0,
        rating: 4.7,
        reviewCount: 88,
        imageUrl:
            'https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=600&q=80',
        description:
            'Ultra-slim 7mm profile watch with breathable Milanese magnetic mesh strap, beloved by Nigerian corporate professionals and brides.',
        isAvailable: true,
        isFavorite: false,
      ),
      StoreProduct(
        name: 'Al-Nur Dual His & Hers Luxury Watch Gift Set',
        slug: 'alnur-dual-his-hers-watch-set',
        categoryId: 'wristwatches',
        price: 58000.0,
        originalPrice: 72000.0,
        rating: 5.0,
        reviewCount: 95,
        imageUrl:
            'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=600&q=80',
        description:
            'Matching couple timepieces with Japanese quartz movement and dual-tone gold links, packaged in an embossed velvet gift chest.',
        isAvailable: true,
        isFavorite: true,
      ),

      // 4. FINE JEWELRY & SETS
      StoreProduct(
        name: 'Zainab Luxury Bridal Choker & Earrings Set',
        slug: 'zainab-luxury-bridal-choker-set',
        categoryId: 'jewelries',
        price: 75000.0,
        originalPrice: 95000.0,
        rating: 5.0,
        reviewCount: 140,
        imageUrl:
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80',
        description:
            'High-grade Austrian crystal choker necklace with chandelier drop earrings, handcrafted for Nigerian traditional and white wedding receptions.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: '18K Gold-Layered Dubai Rope Chain Necklace',
        slug: '18k-gold-layered-dubai-rope-chain',
        categoryId: 'jewelries',
        price: 26000.0,
        originalPrice: 34000.0,
        rating: 4.8,
        reviewCount: 115,
        imageUrl:
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=600&q=80',
        description:
            'Heavyweight 5mm twisted rope chain with secure lobster claw clasp. Triple-plated for non-tarnish luster under Nigerian humidity.',
        isAvailable: true,
        isFavorite: false,
      ),
      StoreProduct(
        name: 'Sparkling Tennis Bracelet (4mm White Gold Finish)',
        slug: 'sparkling-tennis-bracelet-4mm',
        categoryId: 'jewelries',
        price: 28000.0,
        originalPrice: 36000.0,
        rating: 4.9,
        reviewCount: 98,
        imageUrl:
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=600&q=80',
        description:
            'Continuous line of four-prong hand-set brilliant round stones with double safety latch. An enduring luxury staple for every wrist.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: 'Kano Royal Filigree Gold Bangle Set (Pair)',
        slug: 'kano-royal-filigree-gold-bangles',
        categoryId: 'jewelries',
        price: 42000.0,
        originalPrice: 52000.0,
        rating: 4.9,
        reviewCount: 82,
        imageUrl:
            'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=600&q=80',
        description:
            'Intricately embossed Northern Nigerian and Arabian filigree motifs on polished gold-tone brass with hidden spring hinges.',
        isAvailable: true,
        isFavorite: false,
      ),

      // 5. RINGS (EVERYDAY & STATEMENT)
      StoreProduct(
        name: 'Emerald Cut Green Crystal Statement Ring',
        slug: 'emerald-cut-green-crystal-statement-ring',
        categoryId: 'rings',
        price: 18500.0,
        originalPrice: 24000.0,
        rating: 4.9,
        reviewCount: 116,
        imageUrl:
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
        description:
            'Vibrant faceted emerald-green centerpiece stone set on an 18K gold-plated band, capturing magnificent light from every angle.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: 'Arabic Calligraphy \'Barakah\' Open Band Ring',
        slug: 'arabic-calligraphy-barakah-ring',
        categoryId: 'rings',
        price: 16000.0,
        originalPrice: 20000.0,
        rating: 4.8,
        reviewCount: 94,
        imageUrl:
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
        description:
            'Adjustable 925 sterling silver band engraved with the Arabic prayer for blessing (Barakah), accented with micro-pave zirconia.',
        isAvailable: true,
        isFavorite: false,
      ),
      StoreProduct(
        name: 'Classic 3-Row Pavé Crystal Eternity Band',
        slug: 'classic-3row-pave-crystal-eternity-band',
        categoryId: 'rings',
        price: 15000.0,
        originalPrice: 19000.0,
        rating: 4.7,
        reviewCount: 84,
        imageUrl:
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=600&q=80',
        description:
            'Triple row of shimmering hand-set cubic zirconia crystals. Perfect for everyday luxury, ring stacking, or vow renewal.',
        isAvailable: true,
        isFavorite: false,
      ),
      StoreProduct(
        name: 'Vintage Black Onyx Signet Ring',
        slug: 'vintage-black-onyx-signet-ring',
        categoryId: 'rings',
        price: 19500.0,
        originalPrice: 25000.0,
        rating: 4.9,
        reviewCount: 76,
        imageUrl:
            'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=600&q=80',
        description:
            'Bold octagonal natural black onyx gemstone encased in heavy gold-tone bezel, favored by both men and women for distinctive elegance.',
        isAvailable: true,
        isFavorite: true,
      ),
    ];

    for (final item in seedItems) {
      await StoreProduct.db.insertRow(session, item);
    }
  }
}
