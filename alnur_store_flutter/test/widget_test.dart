import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alnur_store_flutter/core/router/app_router.dart';
import 'package:alnur_store_flutter/features/categories/views/category_details_view.dart';
import 'package:alnur_store_flutter/features/home/widgets/home_header.dart';
import 'package:alnur_store_flutter/features/onboarding/models/onboarding_item.dart';
import 'package:alnur_store_flutter/features/onboarding/widgets/onboarding_card.dart';
import 'package:alnur_store_flutter/shared/models/product_model.dart';
import 'package:alnur_store_flutter/shared/widgets/app_button.dart';
import 'package:alnur_store_flutter/shared/widgets/product_card.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('OnboardingCard renders editorial tags, headline and badge', (tester) async {
      final item = OnboardingItem.items.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 700,
              width: 380,
              child: OnboardingCard(
                item: item,
                index: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.text(item.categoryTag), findsOneWidget);
      expect(find.text(item.topBadge), findsOneWidget);
      expect(find.text(item.badgeText), findsOneWidget);
      expect(find.text('1/3'), findsOneWidget);
    });
    testWidgets('HomeHeader renders brand elements and handles interaction callbacks', (tester) async {
      bool cartTapped = false;
      bool notificationTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(
              cartCount: 4,
              hasUnreadNotifications: true,
              userName: 'Amina',
              isGuest: false,
              onCartTap: () => cartTapped = true,
              onNotificationTap: () => notificationTapped = true,
            ),
          ),
        ),
      );

      // Verify brand title in RichText and tagline in Text
      final richTextFinder = find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText().contains('Al-Nur'),
      );
      expect(richTextFinder, findsOneWidget);
      expect(find.text('Modest Fashion • Quality • You'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);

      // Verify notification bell icon
      final notificationFinder = find.byIcon(Icons.notifications_none_rounded);
      expect(notificationFinder, findsOneWidget);
      await tester.tap(notificationFinder);
      expect(notificationTapped, isTrue);

      // Verify cart icon
      final cartFinder = find.byIcon(Icons.shopping_cart_outlined);
      expect(cartFinder, findsOneWidget);
      await tester.tap(cartFinder);
      expect(cartTapped, isTrue);
    });

    testWidgets('AppButton renders label and triggers onPressed callback', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Add to Modest Bag',
              onPressed: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Add to Modest Bag'), findsOneWidget);
      await tester.tap(find.text('Add to Modest Bag'));
      expect(buttonPressed, isTrue);
    });

    testWidgets('ProductCard displays product details and triggers gestures', (tester) async {
      bool cardTapped = false;
      bool favoriteToggled = false;

      const product = ProductModel(
        id: 'widget_perfume_1',
        name: 'Royal Amber & Cambodian Oud EDP',
        price: 28500,
        rating: 4.9,
        reviewCount: 32,
        imageUrl: 'https://images.unsplash.com/photo-1594035910387-fea47794261f',
        categoryId: 'perfumes',
        isFavorite: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              onTap: () => cardTapped = true,
              onFavoriteToggle: () => favoriteToggled = true,
            ),
          ),
        ),
      );

      expect(find.text('Royal Amber & Cambodian Oud EDP'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Tap card
      await tester.tap(find.text('Royal Amber & Cambodian Oud EDP'));
      expect(cardTapped, isTrue);

      // Tap favorite button
      await tester.tap(find.byIcon(Icons.favorite));
      expect(favoriteToggled, isTrue);
    });

    testWidgets('CategoryDetailsView renders category header, badges and products', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CategoryDetailsView(
              categoryId: 'perfumes',
            ),
          ),
        ),
      );

      expect(find.text('Perfumes & Oud'), findsWidgets);
      expect(find.text('ROYAL ARABIAN ATTARS & OUD'), findsOneWidget);
      expect(find.textContaining('Products Available'), findsOneWidget);
    });

    test('AppRouter configuration declares all expected routes', () {
      final routes = appRouter.configuration.routes;
      final paths = routes.map((r) => (r as dynamic).path as String).toList();

      expect(paths.contains(AppRoutes.splash), isTrue);
      expect(paths.contains(AppRoutes.home), isTrue);
      expect(paths.contains(AppRoutes.cart), isTrue);
      expect(paths.contains(AppRoutes.selarCheckout), isTrue);
      expect(paths.contains(AppRoutes.orders), isTrue);
      expect(paths.contains(AppRoutes.profile), isTrue);
      expect(paths.contains(AppRoutes.productDetails), isTrue);
      expect(paths.contains(AppRoutes.categoryDetails), isTrue);
      expect(paths.contains(AppRoutes.aiChat), isTrue);
    });
  });
}
