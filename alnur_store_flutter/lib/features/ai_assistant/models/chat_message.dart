enum MessageSender { user, assistant, system }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? suggestedProducts;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.suggestedProducts,
  });
}
