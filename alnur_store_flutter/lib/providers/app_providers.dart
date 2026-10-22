export '../features/ai_assistant/controllers/ai_chat_controller.dart';
export '../features/home/controllers/home_controller.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/controllers/home_controller.dart';

final globalCartCountProvider = Provider<int>((ref) {
  return ref.watch(homeControllerProvider).cartCount;
});
