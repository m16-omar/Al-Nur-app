import 'package:alnur_store_client/alnur_store_client.dart';

enum MessageSender { user, assistant, system }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? suggestedProducts;
  final List<StoreProduct>? products;
  final String? occasion;
  final String? modestyNote;
  final List<String>? suggestedPrompts;
  final double? totalEstimatedCost;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.suggestedProducts,
    this.products,
    this.occasion,
    this.modestyNote,
    this.suggestedPrompts,
    this.totalEstimatedCost,
  });
}
