import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/category_model.dart';

class CategorySection extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<CategoryModel>? onCategorySelected;

  const CategorySection({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 90,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.id == selectedCategoryId;

            return GestureDetector(
              onTap: () => onCategorySelected?.call(category),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Icon Container
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: category.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.8),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        category.fallbackIcon,
                        size: 26,
                        color: isSelected ? AppColors.primary : const Color(0xFF4A3E35),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Label
                  Text(
                    category.name,
                    style: AppTextStyles.categoryLabel.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
