import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/product_card.dart';

class FeaturedProductsSection extends StatelessWidget {
  final List<ProductModel> products;
  final VoidCallback? onViewAllTap;
  final ValueChanged<ProductModel>? onProductTap;
  final ValueChanged<ProductModel>? onFavoriteToggle;

  const FeaturedProductsSection({
    super.key,
    required this.products,
    this.onViewAllTap,
    this.onProductTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: AppTextStyles.sectionTitle,
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: Row(
                  children: [
                    Text('View All', style: AppTextStyles.sectionAction),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Color(0xFF1B4D3E),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal Product List
        SizedBox(
          height: 248,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                width: 155,
                onTap: () => onProductTap?.call(product),
                onFavoriteToggle: () => onFavoriteToggle?.call(product),
              );
            },
          ),
        ),
      ],
    );
  }
}
