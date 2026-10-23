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

      if (lower.contains('abaya') || lower.contains('black')) {
        responseText =
            'I recommend our Classic Black Abaya (₦24,500). Crafted from premium Korean Nida fabric, offering full non-transparent modesty that pairs elegantly with our Silk Chiffon Hijab!';
      } else if (lower.contains('hijab') || lower.contains('scarf')) {
        responseText =
            'Our Pure Medina Silk Hijab (₦8,500) offers breathable elegance with subtle matte luster that never slips.';
      } else if (lower.contains('thobe') || lower.contains('jalabia')) {
        responseText =
            'For congregational prayers and formal events, our Emirati Minimalist White Thobe (₦26,000) tailored from pure Egyptian cotton is an exceptional choice.';
      } else {
        responseText =
            'As-salamu alaykum! I am your Al-Nur AI Stylist. Tell me your preferred occasion (Jumuah, Eid, Nikah, daily wear) or budget, and I will curate an authentic modest ensemble for you.';
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
