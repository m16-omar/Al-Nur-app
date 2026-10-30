import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alnur_store_flutter/features/products/models/product_review.dart';
import 'package:alnur_store_flutter/features/products/repositories/review_repository.dart';
import 'package:alnur_store_flutter/features/products/widgets/write_review_dialog.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProductReview & ReviewRepository Tests', () {
    test('ProductReview model converts to and from JSON', () {
      final review = ProductReview(
        id: 'rev_123',
        productId: 'prod_oud',
        userName: 'Maryam S.',
        userInitial: 'M',
        rating: 5.0,
        title: 'Divine Royal Scent',
        comment: 'Lasted more than 24 hours on silk abaya with royal sillage.',
        date: 'Today',
        tags: ['Authentic Sillage', 'Halal Certified'],
        isVerifiedBuyer: true,
      );

      final json = review.toJson();
      expect(json['id'], 'rev_123');
      expect(json['userName'], 'Maryam S.');
      expect(json['rating'], 5.0);

      final reconstructed = ProductReview.fromJson(json);
      expect(reconstructed.id, review.id);
      expect(reconstructed.userInitial, 'M');
      expect(reconstructed.tags.length, 2);
    });

    test('ReviewRepository returns luxury default seed reviews for perfume', () async {
      final reviews = await ReviewRepository.getReviews(
        productId: 'royal_amber_cambodian_oud',
        categoryId: 'perfumes',
        productName: 'Royal Amber & Cambodian Oud',
      );

      expect(reviews.isNotEmpty, isTrue);
      expect(reviews.any((r) => r.title.contains('Sillage') || r.comment.contains('agarwood')), isTrue);
    });

    test('ReviewRepository saves and retrieves a new user review', () async {
      final newRev = await ReviewRepository.addReview(
        productId: 'test_item_001',
        userName: 'Zaynab K.',
        rating: 5.0,
        title: 'Exquisite Craftsmanship',
        comment: 'The gold finish is pure perfection and arrived beautifully boxed.',
        tags: ['Regal Gift Packaging', '18K Non-Tarnish'],
      );

      expect(newRev.userName, 'Zaynab K.');
      expect(newRev.userInitial, 'Z');
      expect(newRev.isVerifiedBuyer, isTrue);

      final fetched = await ReviewRepository.getReviews(
        productId: 'test_item_001',
        categoryId: 'jewelry',
        productName: 'Gold Ring',
      );

      expect(fetched.first.id, newRev.id);
      expect(fetched.first.comment, 'The gold finish is pure perfection and arrived beautifully boxed.');
    });
  });

  group('WriteReviewDialog Widget Tests', () {
    testWidgets('WriteReviewDialog renders interactive rating, form inputs and feature tags', (tester) async {
      ProductReview? submittedReview;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WriteReviewDialog(
              productId: 'test_product_1',
              productName: 'Royal Amber Oud',
              initialUserName: 'Amina',
              onReviewSubmitted: (review) {
                submittedReview = review;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check title and item name
      expect(find.text('Rate & Review Item'), findsOneWidget);
      expect(find.text('Royal Amber Oud'), findsOneWidget);

      // Check form fields
      expect(find.byType(TextFormField), findsNWidgets(3)); // name, title, comment
      expect(find.text('Amina'), findsOneWidget); // prefilled name

      // Check rating stars exist
      expect(find.byIcon(Icons.star_rounded), findsWidgets);

      // Check submit button
      expect(find.text('Submit Verified Review'), findsOneWidget);

      // Enter review comment and submit
      final commentField = find.byType(TextFormField).last;
      await tester.enterText(commentField, 'Stunning modest elegance and incredible presentation.');
      await tester.pumpAndSettle();

      // Scroll to submit button and tap
      final submitButton = find.text('Submit Verified Review');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(submittedReview, isNotNull);
      expect(submittedReview!.userName, 'Amina');
      expect(submittedReview!.comment, 'Stunning modest elegance and incredible presentation.');
    });
  });
}
