import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/ai_assistant/views/ai_chat_view.dart';
import '../../features/home/views/home_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String aiChat = '/ai-chat';
  static const String cart = '/cart';
  static const String productDetails = '/product/:id';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => HomeView(
        onOpenAiChat: () => context.push(AppRoutes.aiChat),
        onOpenCart: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cart opened')),
          );
        },
        onOpenNotifications: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications opened')),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.aiChat,
      builder: (context, state) => const AiChatView(),
    ),
  ],
);
