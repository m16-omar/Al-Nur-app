import 'package:go_router/go_router.dart';
import '../../features/ai_assistant/views/ai_chat_view.dart';
import '../../features/authentication/views/login_view.dart';
import '../../features/authentication/views/sign_up_view.dart';
import '../../features/cart/views/cart_view.dart';
import '../../features/cart/views/selar_checkout_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/onboarding/views/onboarding_view.dart';
import '../../features/orders/views/orders_view.dart';
import '../../features/splash/views/splash_view.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String home = '/';
  static const String aiChat = '/ai-chat';
  static const String cart = '/cart';
  static const String selarCheckout = '/selar-checkout';
  static const String orders = '/orders';
  static const String productDetails = '/product/:id';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => const SignUpView(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartView(),
    ),
    GoRoute(
      path: AppRoutes.selarCheckout,
      builder: (context, state) => const SelarCheckoutView(),
    ),
    GoRoute(
      path: AppRoutes.orders,
      builder: (context, state) => const OrdersView(),
    ),
    GoRoute(
      path: AppRoutes.aiChat,
      builder: (context, state) => const AiChatView(),
    ),
  ],
);
