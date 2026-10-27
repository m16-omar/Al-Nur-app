import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../idempotency/idempotency_manager.dart';

class ProductEndpoint extends Endpoint {
  /// Fetches products, filtering optionally by categoryId and search query.
  /// Seeds initial Al-Nur catalog products if empty.
  Future<List<StoreProduct>> getProducts(
    Session session, {
    String? categoryId,
    String? search,
  }) async {
    final count = await StoreProduct.db.count(session);
    if (count == 0) {
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
      // Abayas
      StoreProduct(
        name: 'Dubai Gold Noir Abaya',
        slug: 'dubai-gold-noir-abaya',
        categoryId: 'abayas',
        price: 28500.0,
        originalPrice: 35000.0,
        rating: 4.9,
        reviewCount: 142,
        imageUrl:
            'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=500&q=80',
        description:
            'Hand-tailored Dubai crepe abaya featuring intricate golden wrist embroidery and graceful flowing drape.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: 'Classic Black Korean Abaya',
        slug: 'classic-black-korean-abaya',
        categoryId: 'abayas',
        price: 24500.0,
        originalPrice: 29000.0,
        rating: 4.8,
        reviewCount: 118,
        imageUrl:
            'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=500&q=80',
        description:
            'Made from high-grade Korean Nida fabric, offering lightweight modest coverage with deep black finish.',
        isAvailable: true,
        isFavorite: false,
      ),
      StoreProduct(
        name: 'Pearl Beaded Organza Abaya',
        slug: 'pearl-beaded-organza-abaya',
        categoryId: 'abayas',
        price: 38000.0,
        originalPrice: 45000.0,
        rating: 4.9,
        reviewCount: 82,
        imageUrl:
            'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?auto=format&fit=crop&w=500&q=80',
        description:
            'Luxurious double-layer organza abaya with hand-set river pearls along the lapel and cuffs.',
        isAvailable: true,
        isFavorite: true,
      ),
      StoreProduct(
        name: 'Kimono Flare Linen Abaya',
        slug: 'kimono-flare-linen-abaya',
        categoryId: 'abayas',
        price: 27500.0,
        originalPrice: 32000.0,
        rating: 4.7,
        reviewCount: 64,
        imageUrl:
            'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=500&q=80',
        description:
            'Breathable European linen blend in neutral sand, tailored with wide relaxed kimono sleeves.',
        isAvailable: true,
        isFavorite: false,
      ),

      // Hijabs
      StoreProduct(
        name: 'Pure Medina Silk Hijab',
        slug: 'pure-medina-silk-hijab',
        categoryId: 'hijabs',
        price: 8500.0,
        originalPrice: 11000.0,
        rating: 4.8,
        reviewCount: 96,
        imageUrl:
            'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=500&q=80',
        description:
            'Ultra-soft, opaque Medina silk hijab with subtle luster, breathable for all-day comfort.',
        isAvailable: true,
        isFavorite: false,
      ),
      StoreProduct(
        name: 'Rose Chiffon Everyday Hijab',
        slug: 'rose-chiffon-everyday-hijab',
        categoryId: 'hijabs',
        price: 7500.0,
        originalPrice: 9500.0,
        rating: 4.8,
        reviewCount: 78,
        imageUrl:
            'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=500&q=80',
        description:
            'Lightweight, breathable luxury chiffon that drapes gracefully without slipping.',
        isAvailable: true,
        isFavorite: true,
      ),

      // Jalabias
      StoreProduct(
        name: 'Moroccan Royal Emerald Jalabia',
        slug: 'moroccan-royal-emerald-jalabia',
        categoryId: 'jalabias',
        price: 36000.0,
        originalPrice: 42000.0,
        rating: 4.9,
        reviewCount: 68,
        imageUrl:
            'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=500&q=80',
        description:
            'Exquisite Moroccan Sfifa embroidery on premium emerald velvet with handmade sfifa buttons.',
        isAvailable: true,
        isFavorite: true,
      ),

      // Thobes
      StoreProduct(
        name: 'Emirati Minimalist White Thobe',
        slug: 'emirati-minimalist-white-thobe',
        categoryId: 'thobes',
        price: 26000.0,
        originalPrice: 32000.0,
        rating: 4.8,
        reviewCount: 57,
        imageUrl:
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=500&q=80',
        description:
            'Crisp white cotton thobe with round collar, tailored for daily prayer, Friday Jumuah, and formal events.',
        isAvailable: true,
        isFavorite: false,
      ),

      // Perfumes
      StoreProduct(
        name: 'Royal Oud Signature Flacon',
        slug: 'royal-oud-signature',
        categoryId: 'perfumes',
        price: 18000.0,
        originalPrice: 22000.0,
        rating: 5.0,
        reviewCount: 110,
        imageUrl:
            'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=500&q=80',
        description:
            'Smoky Cambodian oud with a warm amber-vanilla finish. Suitable for Jumuah and festive evenings.',
        isAvailable: true,
        isFavorite: true,
      ),

      // Jewelries
      StoreProduct(
        name: 'Aisha Bridal Heirloom Set',
        slug: 'aisha-bridal-heirloom-set',
        categoryId: 'jewelries',
        price: 55000.0,
        originalPrice: 65000.0,
        rating: 4.9,
        reviewCount: 45,
        imageUrl:
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=500&q=80',
        description:
            '18k gold-finish bridal set complete with necklace, matching drop earrings, bangles and ornate ring.',
        isAvailable: true,
        isFavorite: true,
      ),
    ];

    for (final item in seedItems) {
      await StoreProduct.db.insertRow(session, item);
    }
  }
}
