import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_review.dart';

class ReviewRepository {
  static const String _storagePrefix = 'alnur_reviews_';

  /// Fetches reviews for a product: saved user reviews + category-matched luxury seed reviews.
  static Future<List<ProductReview>> getReviews({
    required String productId,
    required String categoryId,
    required String productName,
  }) async {
    final List<ProductReview> userReviews = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix$productId';
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            userReviews.add(ProductReview.fromJson(item));
          }
        }
      }
    } catch (e) {
      debugPrint('[ReviewRepository] Error reading cached reviews: $e');
    }

    // Curated seed reviews matching current luxury catalog
    final seedReviews = _getSeedReviews(productId, categoryId, productName);

    return [...userReviews, ...seedReviews];
  }

  /// Saves a new review to local storage and returns the created model.
  static Future<ProductReview> addReview({
    required String productId,
    required String userName,
    required double rating,
    required String title,
    required String comment,
    List<String> tags = const [],
  }) async {
    final initial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'A';
    final newReview = ProductReview(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      userName: userName.trim().isNotEmpty ? userName.trim() : 'Verified Buyer',
      userInitial: initial,
      rating: rating,
      title: title.trim(),
      comment: comment.trim(),
      date: 'Just now',
      tags: tags,
      isVerifiedBuyer: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix$productId';
      final existingRaw = prefs.getString(key);
      List<dynamic> list = [];
      if (existingRaw != null && existingRaw.isNotEmpty) {
        try {
          list = jsonDecode(existingRaw) as List<dynamic>;
        } catch (_) {}
      }
      list.insert(0, newReview.toJson());
      await prefs.setString(key, jsonEncode(list));
    } catch (e) {
      debugPrint('[ReviewRepository] Error saving review: $e');
    }

    return newReview;
  }

  static List<ProductReview> _getSeedReviews(
    String productId,
    String categoryId,
    String productName,
  ) {
    final cat = categoryId.toLowerCase();
    if (cat.contains('perfume') || cat.contains('oud')) {
      return [
        ProductReview(
          id: 'seed_perfume_1',
          productId: productId,
          userName: 'Dr. Ibrahim Al-Hassan',
          userInitial: 'I',
          rating: 5.0,
          title: 'Unbelievable 14-Hour Sillage for Jumu’ah',
          comment:
              'The authentic Cambodian agarwood notes develop magnificently throughout the day in humid Lagos weather. Compliments flowed continuously at the mosque.',
          date: '3 days ago',
          tags: const ['👑 Authentic Sillage', '🌿 Pure Cambodian Oud', '🎁 Velvet Box'],
        ),
        ProductReview(
          id: 'seed_perfume_2',
          productId: productId,
          userName: 'Amina Bello',
          userInitial: 'A',
          rating: 5.0,
          title: 'Regal Wedding Gift Presentation',
          comment:
              'Ordered this for my brother’s Nikah gift set in Abuja. The heavy crystal flacon and golden crest packaging made unboxing feel like royalty.',
          date: 'Last week',
          tags: const ['✨ Regal Packaging', '⭐ 100% Alcohol-Free'],
        ),
      ];
    } else if (cat.contains('ring') || cat.contains('wedding')) {
      return [
        ProductReview(
          id: 'seed_ring_1',
          productId: productId,
          userName: 'Engr. Usman & Fatima',
          userInitial: 'U',
          rating: 5.0,
          title: 'Flawless 18K Luster & Comfort Fit',
          comment:
              'We wore these marital bands for our wedding reception and daily wear. Completely non-tarnish and sweat-resistant. The brushed satin finish is stunning.',
          date: '4 days ago',
          tags: const ['💍 Non-Tarnish 18K', '✨ Curved Comfort Fit', '💎 Matching Pair'],
        ),
        ProductReview(
          id: 'seed_ring_2',
          productId: productId,
          userName: 'Hajiya Zainab M.',
          userInitial: 'Z',
          rating: 5.0,
          title: 'Heirloom Craftsmanship',
          comment:
              'Heavy solid feel with precise hallmarking. Fits exactly true to size and arrived inside a velvet gift case with authenticity certificate.',
          date: '2 weeks ago',
          tags: const ['👑 True to Size', '📦 Express Delivery'],
        ),
      ];
    } else if (cat.contains('watch')) {
      return [
        ProductReview(
          id: 'seed_watch_1',
          productId: productId,
          userName: 'Alhaji Mansur K.',
          userInitial: 'M',
          rating: 5.0,
          title: 'Striking Sunburst Dial & Weight',
          comment:
              'The Austrian crystal diamond bezel sparkles brilliantly in daylight. Jubilee bracelet adjusts easily and looks phenomenal with my white agbada.',
          date: '5 days ago',
          tags: const ['⌚ Austrian Crystals', '✨ 18K Rose Gold Plate'],
        ),
        ProductReview(
          id: 'seed_watch_2',
          productId: productId,
          userName: 'Khadija Sani',
          userInitial: 'K',
          rating: 4.8,
          title: 'High-End Luxury Watch for Owambe',
          comment:
              'Substantial wrist presence and accurate quartz movement. Everyone at the Kano reception asked where I got it.',
          date: '10 days ago',
          tags: const ['💎 Premium Weight', '🎁 Luxury Case'],
        ),
      ];
    } else {
      return [
        ProductReview(
          id: 'seed_jewelry_1',
          productId: productId,
          userName: 'Aisha Mohammed',
          userInitial: 'A',
          rating: 5.0,
          title: 'Radiant Bridal Elegance',
          comment:
              'The crystal choker necklace sparkles with royal brilliance and does not pull or tarnish. An absolute centerpiece for our wedding.',
          date: '2 days ago',
          tags: const ['👑 Bridal Centerpiece', '✨ Austrian Crystals'],
        ),
        ProductReview(
          id: 'seed_jewelry_2',
          productId: productId,
          userName: 'Maryam Danjuma',
          userInitial: 'M',
          rating: 5.0,
          title: 'Worth Every Naira',
          comment:
              'Craftsmanship is breathtaking. The gift packaging and velvet lining made it feel like buying from Dubai’s gold souk.',
          date: '1 week ago',
          tags: const ['🎁 Luxe Gift Box', '⚡ Fast Delivery'],
        ),
      ];
    }
  }
}

