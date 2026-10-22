import '../../../shared/models/product_model.dart';

class ProductRecommendation {
  final ProductModel product;
  final String matchReason;
  final double confidenceScore;

  const ProductRecommendation({
    required this.product,
    required this.matchReason,
    this.confidenceScore = 0.95,
  });
}
