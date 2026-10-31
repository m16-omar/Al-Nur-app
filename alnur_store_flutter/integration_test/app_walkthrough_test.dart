import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alnur_store_flutter/main.dart' as entrypoint;
import 'package:alnur_store_flutter/core/router/app_router.dart';
import 'package:alnur_store_flutter/features/onboarding/services/onboarding_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Al-Nur Store Complete Pitch Walkthrough: Mobile, AI, Payment & Reviews', (WidgetTester tester) async {
    // Reset preferences so we start fresh from Splash & Onboarding
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
    await OnboardingPreferences.setOnboardingCompleted(completed: false);

    // Launch main app
    entrypoint.main();
    await tester.pumpAndSettle();

    // 1. SPLASH SCREEN (Golden Islamic Monogram & Shimmer)
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 2. ONBOARDING WALKTHROUGH (Luxury Modesty Value Proposition)
    // Card 1: Haute Modesty
    await Future.delayed(const Duration(seconds: 3));
    final continueFinder = find.text('Continue');
    if (continueFinder.evaluate().isNotEmpty) {
      await tester.tap(continueFinder.first);
      await tester.pumpAndSettle();
    }

    // Card 2: Ethical Craftsmanship
    await Future.delayed(const Duration(seconds: 3));
    if (continueFinder.evaluate().isNotEmpty) {
      await tester.tap(continueFinder.first);
      await tester.pumpAndSettle();
    }

    // Card 3: Bespoke Scenting & Concierge
    await Future.delayed(const Duration(seconds: 3));
    final signInFinder = find.textContaining('Sign In');
    if (signInFinder.evaluate().isNotEmpty) {
      await tester.tap(signInFinder.first);
      await tester.pumpAndSettle();
    } else {
      appRouter.go(AppRoutes.login);
      await tester.pumpAndSettle();
    }

    // 3. LOGIN SCREEN (Authenticating Fatima Al-Mansoor)
    await Future.delayed(const Duration(seconds: 3));
    final textFields = find.byType(TextField);
    if (textFields.evaluate().length >= 2) {
      // Enter Email: fatima@alnur.store
      await tester.enterText(textFields.at(0), 'fatima@alnur.store');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 1500));

      // Enter Password: Fatima@
      await tester.enterText(textFields.at(1), 'Fatima@');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 1800));
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
    await Future.delayed(const Duration(seconds: 4));

    // 4. MEMBER WELCOME GIFT MODAL (15% OFF ALNUR15)
    final startExploringFinder = find.textContaining('Start Exploring Collections');
    if (startExploringFinder.evaluate().isNotEmpty) {
      await Future.delayed(const Duration(seconds: 4));
      await tester.tap(startExploringFinder.first);
      await tester.pumpAndSettle();
    }

    // 5. HOME SCREEN & HAUTE COLLECTIONS
    await Future.delayed(const Duration(seconds: 4));
    final homeScrollable = find.byType(Scrollable);
    if (homeScrollable.evaluate().isNotEmpty) {
      await tester.drag(homeScrollable.first, const Offset(0, -320));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // Toggle modesty wishlist favorite
      final favIcon = find.byIcon(Icons.favorite_border_rounded);
      if (favIcon.evaluate().isNotEmpty) {
        await tester.tap(favIcon.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // 6. AI MODESTY STYLIST (Gemini-Powered Halal Haute Couture Advisor)
    Finder? aiTabFinder;
    if (find.text('AI Stylist').evaluate().isNotEmpty) {
      aiTabFinder = find.text('AI Stylist').first;
    } else if (find.byIcon(Icons.auto_awesome).evaluate().isNotEmpty) {
      aiTabFinder = find.byIcon(Icons.auto_awesome).first;
    }

    if (aiTabFinder != null) {
      await tester.tap(aiTabFinder);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 4));

      // Send styling prompt
      final aiInput = find.byType(TextField);
      if (aiInput.evaluate().isNotEmpty) {
        await tester.enterText(aiInput.last, 'Recommend a modest abaya with oud scent for an evening Nikah');
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 2));

        final sendBtn = find.byIcon(Icons.send_rounded);
        if (sendBtn.evaluate().isNotEmpty) {
          await tester.tap(sendBtn.first);
          await tester.pumpAndSettle();
          // Allow time for the AI response to be read by judges & investors
          await Future.delayed(const Duration(seconds: 6));
        }
      }

      // Return to Home tab
      Finder? homeTab;
      if (find.text('Home').evaluate().isNotEmpty) {
        homeTab = find.text('Home').first;
      } else if (find.byIcon(Icons.home_rounded).evaluate().isNotEmpty) {
        homeTab = find.byIcon(Icons.home_rounded).first;
      }
      if (homeTab != null) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 3));
      }
    }

    // 7. PRODUCT DETAILS & VERIFIED REVIEWS
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
      await tester.tap(targetProduct);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 4));

      // Scroll down to reviews section
      final prodScrollable = find.byType(Scrollable);
      if (prodScrollable.evaluate().isNotEmpty) {
        await tester.drag(prodScrollable.first, const Offset(0, -450));
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 3));
      }

      // Open newly implemented Rating & Review Form
      final writeReviewBtn = find.text('Write Review');
      if (writeReviewBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(writeReviewBtn.first);
        await tester.pumpAndSettle();
        await tester.tap(writeReviewBtn.first);
        await tester.pumpAndSettle();
        // Give judges time to see the verified review dialog with 5-star rating selector
        await Future.delayed(const Duration(seconds: 4));

        // Dismiss review dialog
        final closeReview = find.byIcon(Icons.close_rounded);
        if (closeReview.evaluate().isNotEmpty) {
          await tester.tap(closeReview.first);
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      }

      // Add product to shopping bag
      final addToBagBtn = find.text('Add to Bag');
      if (addToBagBtn.evaluate().isNotEmpty) {
        await tester.tap(addToBagBtn.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 3));
      }
    }

    // 8. SHOPPING BAG & FULL PAYMENT FLOW
    appRouter.go(AppRoutes.cart);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 4));

    // Proceed to Checkout
    final checkoutBtn = find.textContaining('Proceed to Checkout');
    if (checkoutBtn.evaluate().isNotEmpty) {
      await tester.tap(checkoutBtn.first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      // Select Monnify Dynamic Gateway option
      final monnifyOption = find.textContaining('Monnify');
      if (monnifyOption.evaluate().isNotEmpty) {
        await tester.tap(monnifyOption.first);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 4));
      }
    }

    // On Monnify Checkout Screen: Click "I Have Paid"
    Finder? iHavePaidBtn;
    if (find.textContaining('I Have Paid').evaluate().isNotEmpty) {
      iHavePaidBtn = find.textContaining('I Have Paid').first;
    } else if (find.textContaining('I Have Completed Payment').evaluate().isNotEmpty) {
      iHavePaidBtn = find.textContaining('I Have Completed Payment').first;
    } else if (find.textContaining('I Have Transferred').evaluate().isNotEmpty) {
      iHavePaidBtn = find.textContaining('I Have Transferred').first;
    }

    if (iHavePaidBtn != null) {
      await tester.tap(iHavePaidBtn);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      // Confirm in dialog if verification dialog appears
      Finder? confirmVerify;
      if (find.widgetWithText(ElevatedButton, 'Yes, I Have Paid').evaluate().isNotEmpty) {
        confirmVerify = find.widgetWithText(ElevatedButton, 'Yes, I Have Paid').last;
      } else if (find.textContaining('Yes').evaluate().isNotEmpty) {
        confirmVerify = find.textContaining('Yes').last;
      }

      if (confirmVerify != null) {
        await tester.tap(confirmVerify);
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(seconds: 4));
      }
    }

    // Green Confirmation Modal: "Alhamdulillah! Payment Confirmed"
    final trackOrderBtn = find.textContaining('View & Track My Order');
    if (trackOrderBtn.evaluate().isNotEmpty) {
      await Future.delayed(const Duration(seconds: 4));
      await tester.tap(trackOrderBtn.first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 4));
    } else {
      appRouter.go(AppRoutes.orders);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 4));
    }

    // 9. MY MODEST ORDERS & OFFICIAL INVOICE
    final viewInvoiceBtn = find.text('View Invoice');
    if (viewInvoiceBtn.evaluate().isNotEmpty) {
      await tester.tap(viewInvoiceBtn.first);
      await tester.pumpAndSettle();
      // Allow judges to see itemized invoice with VAT, order reference & tailoring details
      await Future.delayed(const Duration(seconds: 4));

      // Close invoice
      final closeInvoice = find.byIcon(Icons.close_rounded);
      if (closeInvoice.evaluate().isNotEmpty) {
        await tester.tap(closeInvoice.first);
        await tester.pumpAndSettle();
      }
    }

    // 10. PROFILE & SIGN OUT
    appRouter.go(AppRoutes.profile);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    final profileScrollable = find.byType(Scrollable);
    if (profileScrollable.evaluate().isNotEmpty) {
      await tester.drag(profileScrollable.first, const Offset(0, -500));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));
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
        await Future.delayed(const Duration(seconds: 4));
      }
    }

    // Final hold on Welcome / Sign In screen
    await Future.delayed(const Duration(seconds: 4));
  });
}
