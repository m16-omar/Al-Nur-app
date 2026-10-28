import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class CategoryEndpoint extends Endpoint {
  /// Fetches all active store categories, seeding default categories if empty.
  Future<List<StoreCategory>> getCategories(Session session) async {
    final existing = await StoreCategory.db.find(
      session,
      orderBy: (t) => t.id,
    );

    if (existing.isNotEmpty) {
      return existing;
    }

    // Seed default Al-Nur luxury collections
    final defaultCategories = [
      StoreCategory(
        categoryId: 'abayas',
        name: 'Abayas',
        iconName: 'dry_cleaning_rounded',
        tagline: 'Flowing Dubai Nida & Organza Silhouettes',
        intro: 'Handcrafted abayas for modest elegance and special occasions.',
        colorHex: '0xFFF5EFE6',
      ),
      StoreCategory(
        categoryId: 'hijabs',
        name: 'Hijabs',
        iconName: 'all_inclusive_rounded',
        tagline: 'Pure Medina Silk & Breathable Chiffon',
        intro: 'Drape effortlessly with premium non-slip Islamic veils.',
        colorHex: '0xFFE8F1EC',
      ),
      StoreCategory(
        categoryId: 'jalabias',
        name: 'Jalabias',
        iconName: 'auto_awesome_outlined',
        tagline: 'Moroccan Sfifa & Royal Gulf Cut',
        intro: 'Exquisite embroidery and jewel-toned fabrics for gatherings.',
        colorHex: '0xFFFBF4E6',
      ),
      StoreCategory(
        categoryId: 'thobes',
        name: 'Thobes',
        iconName: 'person_rounded',
        tagline: 'Crisp Emirati & Saudi Jubbahs',
        intro: 'Tailored minimalist white and luxury linen thobes.',
        colorHex: '0xFFE9F0FA',
      ),
      StoreCategory(
        categoryId: 'perfumes',
        name: 'Perfumes',
        iconName: 'spa_rounded',
        tagline: 'Signature Oud Blends & Musks',
        intro: 'Long-lasting oriental and floral perfumes suited for prayer and events.',
        colorHex: '0xFFF5EDF9',
      ),
      StoreCategory(
        categoryId: 'jewelries',
        name: 'Jewelries',
        iconName: 'diamond_outlined',
        tagline: 'Heirloom Gold & Pearl Accents',
        intro: 'Bridal sets, bangles and necklaces in rich gold finish.',
        colorHex: '0xFFFDF7E7',
      ),
    ];

    for (final cat in defaultCategories) {
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
