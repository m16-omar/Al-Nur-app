import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alnur_store_flutter/main.dart' as entrypoint;
import 'package:alnur_store_flutter/core/router/app_router.dart';
import 'package:alnur_store_flutter/features/onboarding/services/onboarding_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Al-Nur Store Complete App Flow Walkthrough for Pitch Demo', (WidgetTester tester) async {
    // Reset preferences so we start fresh from Splash & Onboarding
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
    await OnboardingPreferences.setOnboardingCompleted(completed: false);

    // Launch main app
    entrypoint.main();
    await tester.pumpAndSettle();

    // 1. SPLASH SCREEN (Golden Islamic 3D Monogram & Shimmer)
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 2. ONBOARDING WALKTHROUGH
    // Card 1: Curated Luxury
    await Future.delayed(const Duration(seconds: 2));
    final continueFinder = find.text('Continue');
    if (continueFinder.evaluate().isNotEmpty) {
      await tester.tap(continueFinder.first);
      await tester.pumpAndSettle();
    }

    // Card 2: Artisanal Modest Craftsmanship
    await Future.delayed(const Duration(seconds: 2));
    if (continueFinder.evaluate().isNotEmpty) {
      await tester.tap(continueFinder.first);
      await tester.pumpAndSettle();
    }

    // Card 3: Regal Oud & Bespoke Jewelry
    await Future.delayed(const Duration(seconds: 2));
    final signInFinder = find.textContaining('Sign In');
    if (signInFinder.evaluate().isNotEmpty) {
      await tester.tap(signInFinder.first);
      await tester.pumpAndSettle();
    } else {
      appRouter.go(AppRoutes.login);
      await tester.pumpAndSettle();
    }

    // 3. LOGIN SCREEN
    await Future.delayed(const Duration(seconds: 2));
    final textFields = find.byType(TextField);
    if (textFields.evaluate().length >= 2) {
      // Enter Email
      await tester.enterText(textFields.at(0), 'uabdullahi676@gmail.com');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 1200));

      // Enter Password
      await tester.enterText(textFields.at(1), 'Um1600595@');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    // Tap "Sign In"
    final submitLoginFinder = find.widgetWithText(ElevatedButton, 'Sign In');
    if (submitLoginFinder.evaluate().isNotEmpty) {
      await tester.tap(submitLoginFinder.first);
    } else {
      final anySignIn = find.text('Sign In');
      if (anySignIn.evaluate().isNotEmpty) {
        await tester.tap(anySignIn.first);
      }
    }
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    // 4. WELCOME GIFT VOUCHER MODAL (15% OFF ALNUR15)
    final startExploringFinder = find.textContaining('Start Exploring Collections');
    if (startExploringFinder.evaluate().isNotEmpty) {
      await Future.delayed(const Duration(seconds: 3));
      await tester.tap(startExploringFinder.first);
      await tester.pumpAndSettle();
    }

    // 5. HOME SCREEN TOUR
    await Future.delayed(const Duration(seconds: 3));
    // Scroll down to showcase collections & arch-framed layout
    final homeScrollable = find.byType(Scrollable);
    if (homeScrollable.evaluate().isNotEmpty) {
      await tester.drag(homeScrollable.first, const Offset(0, -320));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      // Toggle favorite on featured piece
      final favIcon = find.byIcon(Icons.favorite_border_rounded);
      if (favIcon.evaluate().isNotEmpty) {
        await tester.tap(favIcon.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }

    // 6. PRODUCT DETAILS & VERIFIED REVIEWS
    // Find visible product card
    Finder? targetProduct;
    final candidates = [
      find.textContaining('Dubai 18K Solid Gold'),
      find.textContaining('Royal Amber'),
      find.textContaining('Gold-Bonded'),
      find.textContaining('Dubai'),
      find.textContaining('Oud'),
    ];

    for (final c in candidates) {
      if (c.evaluate().isNotEmpty) {
        targetProduct = c.first;
        break;
      }
    }

    if (targetProduct != null) {
      await tester.ensureVisible(targetProduct);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 800));
      await tester.tap(targetProduct);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // Scroll down to reviews section
      final prodScrollable = find.byType(Scrollable);
      if (prodScrollable.evaluate().isNotEmpty) {
        await tester.drag(prodScrollable.first, const Offset(0, -450));
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 2));
      }

      // Demonstrate the new Rating & Review Form
      final writeReviewBtn = find.text('Write Review');
      if (writeReviewBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(writeReviewBtn.first);
        await tester.pumpAndSettle();
        await tester.tap(writeReviewBtn.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 3));

        // Dismiss review dialog
        final closeReview = find.byIcon(Icons.close_rounded);
        if (closeReview.evaluate().isNotEmpty) {
          await tester.tap(closeReview.first);
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }

      // Add product to bag
      final addToBagBtn = find.text('Add to Bag');
      if (addToBagBtn.evaluate().isNotEmpty) {
        await tester.tap(addToBagBtn.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // 7. CART / MODEST SHOPPING BAG
    appRouter.go(AppRoutes.cart);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    // Proceed to Checkout options
    final checkoutBtn = find.textContaining('Proceed to Checkout');
    if (checkoutBtn.evaluate().isNotEmpty) {
      await tester.tap(checkoutBtn.first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      // Dismiss payment options
      final dismissBtn = find.byIcon(Icons.close_rounded);
      if (dismissBtn.evaluate().isNotEmpty) {
        await tester.tap(dismissBtn.first);
        await tester.pumpAndSettle();
      }
    }

    // 8. MY MODEST ORDERS & TRACKING
    appRouter.go(AppRoutes.orders);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    // View official invoice breakdown
    final viewInvoiceBtn = find.text('View Invoice');
    if (viewInvoiceBtn.evaluate().isNotEmpty) {
      await tester.tap(viewInvoiceBtn.first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // Dismiss invoice
      final closeInvoice = find.byIcon(Icons.close_rounded);
      if (closeInvoice.evaluate().isNotEmpty) {
        await tester.tap(closeInvoice.first);
        await tester.pumpAndSettle();
      }
    }

    // 9. PROFILE & SIGN OUT
    appRouter.go(AppRoutes.profile);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    final profileScrollable = find.byType(Scrollable);
    if (profileScrollable.evaluate().isNotEmpty) {
      await tester.drag(profileScrollable.first, const Offset(0, -500));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
    }

    final signOutBtn = find.textContaining('Sign Out');
    if (signOutBtn.evaluate().isNotEmpty) {
      await tester.ensureVisible(signOutBtn.first);
      await tester.pumpAndSettle();
      await tester.tap(signOutBtn.first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      Finder? confirmSignOut;
      if (find.widgetWithText(ElevatedButton, 'Sign Out').evaluate().isNotEmpty) {
        confirmSignOut = find.widgetWithText(ElevatedButton, 'Sign Out').last;
      } else if (find.text('Sign Out').evaluate().isNotEmpty) {
        confirmSignOut = find.text('Sign Out').last;
      }

      if (confirmSignOut != null) {
        await tester.tap(confirmSignOut);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 3));
      }
    }

    // Final showcase hold on Welcome / Sign In screen
    await Future.delayed(const Duration(seconds: 3));
  });
}
