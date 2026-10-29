import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class CategoryEndpoint extends Endpoint {
  /// Default official Al-Nur collections: Rings, Perfumes, Jewelries, Wedding Rings, Wristwatches
  static List<StoreCategory> get defaultOfficialCategories => [
        StoreCategory(
          categoryId: 'perfumes',
          name: 'Perfumes & Oud',
          iconName: 'spa_rounded',
          tagline: 'Royal Arabian Oud, Vanilla & Musks',
          intro: 'Long-lasting concentrated perfume oils and royal Arabian scents crafted for Nigerian celebrations.',
          colorHex: '0xFFF5EDF9',
        ),
        StoreCategory(
          categoryId: 'wedding-rings',
          name: 'Wedding Rings',
          iconName: 'diamond_rounded',
          tagline: '18K Gold Plated & Moissanite Sets',
          intro: 'Timeless matching couple bands and bridal proposal rings crafted for Nigerian weddings.',
          colorHex: '0xFFFDF7E7',
        ),
        StoreCategory(
          categoryId: 'wristwatches',
          name: 'Wristwatches',
          iconName: 'watch_outlined',
          tagline: 'Diamond-Bezel & Luxury Steel Timepieces',
          intro: 'Precision quartz and automatic wristwatches for elegant men, women, and couples.',
          colorHex: '0xFFE9F0FA',
        ),
        StoreCategory(
          categoryId: 'jewelries',
          name: 'Fine Jewelry',
          iconName: 'auto_awesome_rounded',
          tagline: 'Bridal Chokers, Dubai Chains & Bangles',
          intro: 'Exquisite Austrian crystal necklaces, tennis bracelets, and non-tarnish gold jewelry.',
          colorHex: '0xFFF9EAE1',
        ),
        StoreCategory(
          categoryId: 'rings',
          name: 'Rings',
          iconName: 'circle_outlined',
          tagline: 'Everyday Luxury, Gemstones & Signet Bands',
          intro: 'Hand-finished emerald crystals, signets and barakah statement rings.',
          colorHex: '0xFFE8F1EC',
        ),
      ];

  /// Fetches all active store categories, migrating legacy categories if present.
  Future<List<StoreCategory>> getCategories(Session session) async {
    final existing = await StoreCategory.db.find(
      session,
      orderBy: (t) => t.id,
    );

    final bool hasLegacy = existing.any((c) =>
        c.categoryId == 'abayas' ||
        c.categoryId == 'hijabs' ||
        c.categoryId == 'jalabias' ||
        c.categoryId == 'thobes' ||
        c.categoryId == 'silk-khimars' ||
        c.categoryId == 'prayer' ||
        c.categoryId == 'jilbabs' ||
        c.categoryId == 'khimars');

    if (existing.isNotEmpty && !hasLegacy) {
      return existing;
    }

    if (hasLegacy) {
      for (final cat in existing) {
        await StoreCategory.db.deleteRow(session, cat);
      }
    }

    for (final cat in defaultOfficialCategories) {
      await StoreCategory.db.insertRow(session, cat);
    }

    return await StoreCategory.db.find(
      session,
      orderBy: (t) => t.id,
    );
  }

  /// Explicitly reseeds the store categories to the official 5 luxury departments.
  Future<List<StoreCategory>> reseedCategories(Session session) async {
    final existing = await StoreCategory.db.find(session);
    for (final cat in existing) {
      await StoreCategory.db.deleteRow(session, cat);
    }
    for (final cat in defaultOfficialCategories) {
      await StoreCategory.db.insertRow(session, cat);
    }
    return await StoreCategory.db.find(
      session,
      orderBy: (t) => t.id,
    );
  }

  /// Creates a new category.
  Future<StoreCategory> createCategory(
    Session session,
    StoreCategory category,
  ) async {
    return await StoreCategory.db.insertRow(session, category);
  }

  /// Updates an existing category.
  Future<StoreCategory> updateCategory(
    Session session,
    StoreCategory category,
  ) async {
    return await StoreCategory.db.updateRow(session, category);
  }

  /// Deletes a category by ID.
  Future<bool> deleteCategory(Session session, int id) async {
    final cat = await StoreCategory.db.findById(session, id);
    if (cat == null) return false;
    await StoreCategory.db.deleteRow(session, cat);
    return true;
  }
}
