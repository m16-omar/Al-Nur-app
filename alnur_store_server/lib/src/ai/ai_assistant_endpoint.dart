import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class AiAssistantEndpoint extends Endpoint {
  /// Analyzes customer query, modesty guidelines, budget, and occasion,
  /// matching catalog products from the PostgreSQL database and providing
  /// personalized Islamic Haute Couture styling advice.
  Future<AiStylistResponse> query(
    Session session,
    String userQuery, {
    double? budget,
    String? occasion,
    String? preferredCategory,
  }) async {
    final queryLower = userQuery.toLowerCase().trim();

    // 1. Detect occasion if not explicitly supplied
    final detectedOccasion = occasion ?? _detectOccasion(queryLower);

    // 2. Detect budget if not explicitly supplied
    final effectiveBudget = budget ?? _extractBudget(queryLower);

    // 3. Retrieve available products from database
    final allProducts = await StoreProduct.db.find(
      session,
      where: (t) => t.isAvailable.equals(true),
      orderBy: (t) => t.rating,
      orderDescending: true,
    );

    // 4. Select tailored product recommendations
    final recommendations = _matchProducts(
      allProducts: allProducts,
      query: queryLower,
      occasion: detectedOccasion,
      budget: effectiveBudget,
      preferredCategory: preferredCategory,
    );

    final totalEstimatedCost = recommendations.fold<double>(
      0.0,
      (sum, p) => sum + p.price,
    );

    // 5. Try calling Gemini if an API key is configured
    final geminiApiKey = session.passwords['geminiApiKey'] ??
        Platform.environment['GEMINI_API_KEY'];

    String? aiReply;
    if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
      try {
        aiReply = await _generateWithGemini(
          session: session,
          apiKey: geminiApiKey,
          query: userQuery,
          occasion: detectedOccasion,
          budget: effectiveBudget,
          products: recommendations,
        );
      } catch (e) {
        session.log(
          'Gemini API call failed, falling back to built-in modest engine: $e',
          level: LogLevel.warning,
        );
      }
    }

    // 6. Built-in Modest Couture Styling Reasoning Engine (deterministic & culturally authentic)
    aiReply ??= _generateModestStylingAdvice(
      query: userQuery,
      occasion: detectedOccasion,
      budget: effectiveBudget,
      products: recommendations,
      totalCost: totalEstimatedCost,
    );

    // 7. Modesty compliance note
    final modestyNote = _buildModestyNote(recommendations, detectedOccasion);

    // 8. Dynamic follow-up chips
    final suggestedPrompts = _buildSuggestedPrompts(detectedOccasion);

    return AiStylistResponse(
      reply: aiReply,
      occasion: detectedOccasion,
      modestyNote: modestyNote,
      recommendedProducts: recommendations,
      suggestedPrompts: suggestedPrompts,
      totalEstimatedCost: totalEstimatedCost,
    );
  }

  String _detectOccasion(String query) {
    if (query.contains('jumuah') ||
        query.contains('jumah') ||
        query.contains('jum\'ah') ||
        query.contains('friday')) {
      return 'Friday Jumuah Prayer & Gathering';
    } else if (query.contains('eid') ||
        query.contains('fitr') ||
        query.contains('adha') ||
        query.contains('sallah')) {
      return 'Eid Celebration & Festive Banquets';
    } else if (query.contains('nikah') ||
        query.contains('wedding') ||
        query.contains('walima') ||
        query.contains('marriage') ||
        query.contains('bridal')) {
      return 'Nikah Ceremony & Royal Wedding Reception';
    } else if (query.contains('work') ||
        query.contains('office') ||
        query.contains('casual') ||
        query.contains('daily') ||
        query.contains('everyday') ||
        query.contains('university')) {
      return 'Daily Office & Contemporary Modest Workwear';
    } else if (query.contains('umrah') ||
        query.contains('hajj') ||
        query.contains('mecca') ||
        query.contains('madinah') ||
        query.contains('ihram')) {
      return 'Sacred Umrah / Hajj Spiritual Journey';
    } else if (query.contains('summer') ||
        query.contains('hot') ||
        query.contains('heat') ||
        query.contains('breathable') ||
        query.contains('linen')) {
      return 'Warm Weather & Breathable Modesty';
    }
    return 'Al-Nur Everyday Haute Couture';
  }

  double? _extractBudget(String query) {
    // Matches patterns like: 50k, 50,000, ₦40000, under 30000
    final kRegex = RegExp(r'(?:under|budget|max|around|₦|ngn)?\s*(\d+(?:\.\d+)?)\s*k\b', caseSensitive: false);
    final kMatch = kRegex.firstMatch(query);
    if (kMatch != null) {
      final val = double.tryParse(kMatch.group(1)!);
      if (val != null) return val * 1000;
    }

    final numRegex = RegExp(r'(?:under|budget|max|around|₦|ngn)\s*(\d{4,6})\b', caseSensitive: false);
    final numMatch = numRegex.firstMatch(query);
    if (numMatch != null) {
      return double.tryParse(numMatch.group(1)!);
    }

    return null;
  }

  List<StoreProduct> _matchProducts({
    required List<StoreProduct> allProducts,
    required String query,
    required String occasion,
    double? budget,
    String? preferredCategory,
  }) {
    if (allProducts.isEmpty) return [];

    final isMaleQuery = RegExp(
      r'\b(men|man|brother|groom|husband)\b',
      caseSensitive: false,
    ).hasMatch(query);

    final isWedding = occasion.contains('Wedding') || occasion.contains('Nikah');
    final isJumuah = occasion.contains('Jumuah');

    final List<StoreProduct> selected = [];

    // Helper to find by category and keywords
    StoreProduct? findProduct(String catId, {List<String>? keywords}) {
      final candidates = allProducts.where((p) => p.categoryId == catId).toList();
      if (candidates.isEmpty) return null;
      if (keywords != null && keywords.isNotEmpty) {
        for (final p in candidates) {
          final text = '${p.name} ${p.description}'.toLowerCase();
          for (final kw in keywords) {
            if (text.contains(kw)) return p;
          }
        }
      }
      return candidates.first;
    }

    if (isMaleQuery) {
      final watch = findProduct('wristwatches', keywords: ['naviforce', 'men']);
      if (watch != null) selected.add(watch);

      final ring = findProduct('rings', keywords: ['onyx', 'signet']) ??
          findProduct('wedding-rings', keywords: ['dubai', 'couple']);
      if (ring != null) selected.add(ring);

      final scent = findProduct('perfumes', keywords: ['cambodian', 'oud']);
      if (scent != null) selected.add(scent);
    } else if (isWedding) {
      final weddingBand = findProduct('wedding-rings', keywords: ['eternal', 'couple', 'halo', 'dubai']);
      if (weddingBand != null) selected.add(weddingBand);

      final jewelry = findProduct('jewelries', keywords: ['bridal', 'choker', 'gold', 'zainab']);
      if (jewelry != null) selected.add(jewelry);

      final watch = findProduct('wristwatches', keywords: ['emerald', 'rose', 'dual']);
      if (watch != null) selected.add(watch);

      final scent = findProduct('perfumes', keywords: ['khamrah', 'oud', 'royal']);
      if (scent != null) selected.add(scent);
    } else if (isJumuah) {
      final scent = findProduct('perfumes', keywords: ['tahara', 'oud', 'amber']);
      if (scent != null) selected.add(scent);

      final ring = findProduct('rings', keywords: ['barakah', 'signet', 'emerald']);
      if (ring != null) selected.add(ring);

      final watch = findProduct('wristwatches', keywords: ['roman', 'naviforce']);
      if (watch != null) selected.add(watch);
    } else {
      // General or specific keyword match
      if (query.contains('watch') || query.contains('timepiece')) {
        final watch = findProduct('wristwatches');
        if (watch != null) selected.add(watch);
      } else if (query.contains('wedding') || query.contains('couple') || query.contains('proposal')) {
        final band = findProduct('wedding-rings');
        if (band != null) selected.add(band);
      } else if (query.contains('ring')) {
        final ring = findProduct('rings') ?? findProduct('wedding-rings');
        if (ring != null) selected.add(ring);
      } else if (query.contains('perfume') || query.contains('oud') || query.contains('scent')) {
        final perfume = findProduct('perfumes');
        if (perfume != null) selected.add(perfume);
      } else if (query.contains('jewelry') || query.contains('necklace') || query.contains('bracelet') || query.contains('bangle')) {
        final jewelry = findProduct('jewelries');
        if (jewelry != null) selected.add(jewelry);
      } else {
        final perfume = findProduct('perfumes');
        if (perfume != null) selected.add(perfume);

        final ring = findProduct('wedding-rings') ?? findProduct('rings');
        if (ring != null) selected.add(ring);

        final watch = findProduct('wristwatches');
        if (watch != null) selected.add(watch);
      }
    }

    // Budget optimization: if budget specified and exceeded, prioritize primary garments
    if (budget != null && selected.isNotEmpty) {
      double currentCost = selected.fold(0.0, (s, p) => s + p.price);
      if (currentCost > budget && selected.length > 1) {
        // Filter to keep the most essential garments under budget
        final withinBudget = selected.where((p) => p.price <= budget).toList();
        if (withinBudget.isNotEmpty) {
          return withinBudget;
        }
      }
    }

    return selected;
  }

  String _generateModestStylingAdvice({
    required String query,
    required String occasion,
    required double? budget,
    required List<StoreProduct> products,
    required double totalCost,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Wa alaykum assalam wa rahmatullah! ✨');
    buffer.writeln();
    buffer.writeln(
      'For **$occasion**, I have curated a balanced, fully opaque modest ensemble adhering to Islamic couture principles:',
    );
    buffer.writeln();

    for (final p in products) {
      final priceFormatted = '₦${p.price.toStringAsFixed(0)}';
      buffer.writeln('• **${p.name}** ($priceFormatted)');
      buffer.writeln('  _${p.description}_');
    }
    buffer.writeln();

    if (budget != null) {
      final budgetFormatted = '₦${budget.toStringAsFixed(0)}';
      final totalFormatted = '₦${totalCost.toStringAsFixed(0)}';
      if (totalCost <= budget) {
        buffer.writeln(
          '💰 **Investment Summary:** Total comes to **$totalFormatted**, perfectly within your **$budgetFormatted** budget!',
        );
      } else {
        buffer.writeln(
          '💰 **Investment Summary:** Total is **$totalFormatted** (Target budget: $budgetFormatted).',
        );
      }
    } else {
      buffer.writeln(
        '💰 **Estimated Set Total:** ₦${totalCost.toStringAsFixed(0)}',
      );
    }

    buffer.writeln();
    buffer.writeln(
      '💡 **Stylist Tip:** Layer Arabian Oud or Musk Tahara on pulse points for an all-day regal scent trail, and complement your rings with a matching diamond-bezel timepiece.',
    );

    return buffer.toString();
  }

  String _buildModestyNote(List<StoreProduct> products, String occasion) {
    return '100% Non-Tarnish Gold Bonded & 925 Sterling Silver Guarantee • Alcohol-Free Royal Arabian Fragrances • Precision Luxury Timepieces.';
  }

  List<String> _buildSuggestedPrompts(String occasion) {
    if (occasion.contains('Jumuah')) {
      return [
        '🌸 Royal Cambodian Oud & Musk Tahara',
        '⌚ Men\'s Naviforce blue dial timepiece',
        '💍 Arabic Barakah engraved silver ring',
        '💰 Best luxury gift under ₦30,000',
      ];
    } else if (occasion.contains('Wedding') || occasion.contains('Nikah')) {
      return [
        '💍 18K Gold couple wedding band sets',
        '✨ Zainab bridal crystal choker & earrings',
        '⌚ His & Hers matching watch gift set',
        '🌸 Lattafa Khamrah & Smoky Bukhoor gift box',
      ];
    } else {
      return [
        '💍 Solitaire engagement rings in sterling silver',
        '⌚ Luxury diamond-bezel wristwatches',
        '🌸 Long-lasting Arabian oud perfumes',
        '✨ Sparkling tennis bracelets & bangles',
      ];
    }
  }

  Future<String?> _generateWithGemini({
    required Session session,
    required String apiKey,
    required String query,
    required String occasion,
    required double? budget,
    required List<StoreProduct> products,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=$apiKey',
    );

    final catalogContext = products
        .map((p) => '${p.name} (₦${p.price.toStringAsFixed(0)}): ${p.description}')
        .join('\n');

    final promptText = '''
You are the Al-Nur Luxury Jewelry, Timepiece & Royal Fragrance AI Stylist in Nigeria.
A customer is asking for luxury styling or gift advice: "$query".
Detected Occasion: $occasion
Customer Budget: ${budget != null ? '₦${budget.toStringAsFixed(0)}' : 'Flexible'}
Recommended Products from catalog:
$catalogContext

Guidelines:
1. Greet with a warm Islamic greeting ("As-salamu alaykum" or "Wa alaykum assalam").
2. Specialize in Wedding Rings, Everyday Statement Rings, Royal Arabian Perfumes/Oud, Fine Jewelry (Chokers, Bangles, Tennis Bracelets), and Luxury Wristwatches.
3. Tailor recommendations for the Nigerian market (Lagos, Abuja, Kano, Port Harcourt), highlighting durability, non-tarnish finishes under humidity, and gifts for weddings, owambe, and Jumu'ah.
4. Always provide prices in Nigerian Naira (₦).
2. Describe why the recommended products pair gracefully together with attention to opaque modest fabrics (Korean Nida, Medina Silk, European Linen), silhouettes, and prayer-safe scent layering.
3. Be respectful, encouraging, elegant, and concise. Mention product prices in Nigerian Naira (₦).
''';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': promptText}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 500,
      }
    });

    final request = await client.postUrl(url);
    request.headers.contentType = ContentType.json;
    request.write(requestBody);
    final response = await request.close().timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] as String?;
        }
      }
    }
    return null;
  }
}
