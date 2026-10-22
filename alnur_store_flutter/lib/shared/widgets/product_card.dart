import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../models/product_model.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteToggle,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with Favorite Button
            Stack(
              children: [
                ProductImage(
                  imageUrl: product.imageUrl,
                  height: 138,
                  width: double.infinity,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: product.isFavorite
                            ? AppColors.notificationRed
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.productTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: AppTextStyles.productPrice,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: AppColors.starAmber,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                        style: AppTextStyles.productRating,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
