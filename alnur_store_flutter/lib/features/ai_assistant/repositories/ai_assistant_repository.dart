import '../models/chat_message.dart';

class AiAssistantRepository {
  Future<ChatMessage> sendMessage(String userQuery) async {
    // In production, this can invoke:
    // final response = await client.aiAssistant.query(userQuery);
    await Future.delayed(const Duration(milliseconds: 600));

    final lower = userQuery.toLowerCase();
    String responseText;

    if (lower.contains('abaya') || lower.contains('black')) {
      responseText =
          'I recommend our Classic Black Abaya (₦18,500). It features premium Korean Nida fabric, subtle wrist embroidery, and pairs beautifully with our Silk Chiffon Hijab!';
    } else if (lower.contains('hijab') || lower.contains('scarf')) {
      responseText =
          'Our Premium Chiffon Hijab (₦7,500) in dusty rose or sage green is a top choice — breathable, wrinkle-resistant, and non-slip.';
    } else if (lower.contains('dress') || lower.contains('maxi')) {
      responseText =
          'Check out our Modest Maxi Dress (₦22,000)! It offers an elegant belted A-line cut that balances modesty and contemporary sophistication.';
    } else {
      responseText =
          'As-salamu alaykum! I am your Al-Nur AI Stylist. Tell me your preferred style, occasion (Eid, wedding, casual, daily work), or budget, and I will curate the best options for you.';
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: responseText,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
    );
  }
}
