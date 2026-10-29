import '../../../main.dart';
import '../models/chat_message.dart';

class AiAssistantRepository {
  Future<ChatMessage> sendMessage(String userQuery) async {
    try {
      final response = await client.aiAssistant.query(userQuery);

      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response.reply,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        products: response.recommendedProducts,
        occasion: response.occasion,
        modestyNote: response.modestyNote,
        suggestedPrompts: response.suggestedPrompts,
        totalEstimatedCost: response.totalEstimatedCost,
      );
    } catch (e) {
      // Graceful offline fallback in case server connection is unavailable
      final lower = userQuery.toLowerCase();
      String responseText;

      if (lower.contains('ring') || lower.contains('wedding')) {
        responseText =
            'For marital celebrations and proposals, I highly recommend our Eternal Vows 18K Gold Plated Couple Wedding Bands (₦68,000) or our Zirconia Solitaire Halo Engagement Ring (₦38,500) crafted in solid 925 sterling silver!';
      } else if (lower.contains('watch') || lower.contains('timepiece')) {
        responseText =
            'Our Geneva Diamond-Bezel Emerald Rose Gold Watch (₦36,000) or Naviforce Royal Men\'s Timepiece (₦32,500) offer water-resistant precision and stunning Nigerian elegance.';
      } else if (lower.contains('perfume') || lower.contains('oud') || lower.contains('scent')) {
        responseText =
            'For an enduring regal scent trail, our Royal Amber & Cambodian Oud EDP (₦28,500) and alcohol-free Pure Musk Tahara (₦14,000) are beloved favorites for Nigerian weddings and Jumu\'ah.';
      } else if (lower.contains('jewelry') || lower.contains('necklace') || lower.contains('choker')) {
        responseText =
            'Our Zainab Luxury Bridal Choker & Earrings Set (₦75,000) features brilliant Austrian crystals designed for Nigerian traditional and white wedding glam.';
      } else {
        responseText =
            'As-salamu alaykum! I am your Al-Nur Luxury Stylist. Tell me your preferred celebration (Wedding, Jumu\'ah, Anniversary, Owambe) or budget, and I will recommend matching Rings, Royal Oud, Fine Jewelry, or Wristwatches.';
      }

      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: responseText,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
      );
    }
  }
}
