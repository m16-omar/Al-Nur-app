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

    final isThobeOrMale = RegExp(
      r'\b(thobe|thobes|jalabiya|jalabias|male|men|man|brother)\b',
      caseSensitive: false,
    ).hasMatch(query);

    final isWedding = occasion.contains('Wedding') || occasion.contains('Nikah');
    final isJumuah = occasion.contains('Jumuah');
    final isLinen = query.contains('linen') || occasion.contains('Warm Weather');

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

    if (isThobeOrMale) {
      final thobe = findProduct('thobes') ?? findProduct('jalabias');
      if (thobe != null) selected.add(thobe);

      final scent = findProduct('perfumes', keywords: ['oud', 'royal']);
      if (scent != null) selected.add(scent);
    } else if (isWedding) {
      final bridalAbaya = findProduct('abayas', keywords: ['organza', 'pearl', 'gold']) ??
          findProduct('jalabias', keywords: ['moroccan', 'emerald']);
      if (bridalAbaya != null) selected.add(bridalAbaya);

      final jewelry = findProduct('jewelries', keywords: ['bridal', 'aisha', 'gold']);
      if (jewelry != null) selected.add(jewelry);

      final silkHijab = findProduct('hijabs', keywords: ['silk', 'medina']);
      if (silkHijab != null) selected.add(silkHijab);

      final oud = findProduct('perfumes');
      if (oud != null) selected.add(oud);
    } else if (isLinen) {
      final linenAbaya = findProduct('abayas', keywords: ['linen', 'kimono']);
      if (linenAbaya != null) selected.add(linenAbaya);

      final chiffon = findProduct('hijabs', keywords: ['chiffon', 'rose', 'breathable']);
      if (chiffon != null) selected.add(chiffon);
    } else if (isJumuah) {
      final jumuahAbaya = findProduct('abayas', keywords: ['korean', 'black', 'nida']) ??
          findProduct('abayas');
      if (jumuahAbaya != null) selected.add(jumuahAbaya);

      final scent = findProduct('perfumes', keywords: ['oud', 'signature']);
      if (scent != null) selected.add(scent);

      final hijab = findProduct('hijabs');
      if (hijab != null) selected.add(hijab);
    } else {
      // General or specific keyword match
      if (query.contains('hijab') || query.contains('scarf')) {
        final hijab = findProduct('hijabs', keywords: ['medina', 'silk']) ?? findProduct('hijabs');
        if (hijab != null) selected.add(hijab);
      } else if (query.contains('perfume') || query.contains('oud') || query.contains('scent')) {
        final perfume = findProduct('perfumes');
        if (perfume != null) selected.add(perfume);
      } else {
        final abaya = findProduct('abayas');
        if (abaya != null) selected.add(abaya);

        final hijab = findProduct('hijabs');
        if (hijab != null) selected.add(hijab);

        final perfume = findProduct('perfumes');
        if (perfume != null) selected.add(perfume);
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
      '💡 **Stylist Tip:** Pair with neutral under-scarves for zero hair slippage, and apply Cambodian Oud on pulse points for an enduring prayer-safe aroma.',
    );

    return buffer.toString();
  }

  String _buildModestyNote(List<StoreProduct> products, String occasion) {
    if (products.any((p) => p.categoryId == 'thobes')) {
      return 'Tailored with loose-fitting drape, opaque natural cotton weave, and wrist-length cut suitable for prayer and Friday congregation.';
    }
    return '100% Non-Transparent Fabric Policy • Generous A-Line Silhouette • Wrist & Ankle Coverage with Opaque Lining.';
  }

  List<String> _buildSuggestedPrompts(String occasion) {
    if (occasion.contains('Jumuah')) {
      return [
        '🌿 Show breathable linen options',
        '🌸 Pair with long-lasting Royal Oud',
        '💰 What can I get under ₦30,000?',
        '🕌 Men\'s Friday thobes & scents',
      ];
    } else if (occasion.contains('Wedding') || occasion.contains('Nikah')) {
      return [
        '💍 View Aisha Bridal Heirloom jewelry',
        '✨ Double-layer organza abayas',
        '🧕 Pure Medina silk scarves in gold',
        '👗 Velvet Moroccan jalabias',
      ];
    } else {
      return [
        '🕌 Jumuah prayer ensemble ideas',
        '✨ Royal Eid modest luxury',
        '🌿 Breathable summer modesty under ₦30k',
        '🌸 Non-alcoholic prayer scents',
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
You are the Al-Nur Luxury Islamic Haute Couture AI Stylist.
A customer is asking for modest fashion advice: "$query".
Detected Occasion: $occasion
Customer Budget: ${budget != null ? '₦' + budget.toStringAsFixed(0) : 'Flexible'}
Recommended Products from catalog:
$catalogContext

Guidelines:
1. Greet with a warm Islamic greeting ("As-salamu alaykum" or "Wa alaykum assalam").
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
