import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../repositories/ai_assistant_repository.dart';

class AiChatState {
  final List<ChatMessage> messages;
  final bool isThinking;

  const AiChatState({
    required this.messages,
    this.isThinking = false,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

class AiChatController extends Notifier<AiChatState> {
  late final AiAssistantRepository _repository;

  @override
  AiChatState build() {
    _repository = ref.watch(aiAssistantRepositoryProvider);
    return AiChatState(
      messages: [
        ChatMessage(
          id: 'welcome',
          text:
              '''As-salamu alaykum! ✨ I am your Al-Nur Personal Luxury Jewelry, Timepiece & Fragrance Stylist.

Need guidance choosing couple wedding rings, selecting long-lasting Arabian oud, or matching a diamond-bezel wristwatch with fine jewelry for an upcoming celebration?''',
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
          suggestedPrompts: const [
            '💍 Couple wedding bands in 18K gold',
            '🌸 Best long-lasting Arabian Oud under ₦30k',
            '⌚ Luxury diamond-bezel wristwatches',
            '✨ Zainab bridal crystal choker & earrings',
          ],
        ),
      ],
    );
  }

  Future<void> sendUserMessage(String query) async {
    if (query.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: query.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
    );

    try {
      final reply = await _repository.sendMessage(query);
      state = state.copyWith(
        messages: [...state.messages, reply],
        isThinking: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I had trouble finding recommendations right now. Please try again.',
        sender: MessageSender.system,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isThinking: false,
      );
    }
  }
}

final aiAssistantRepositoryProvider = Provider<AiAssistantRepository>((ref) {
  return AiAssistantRepository();
});

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);
