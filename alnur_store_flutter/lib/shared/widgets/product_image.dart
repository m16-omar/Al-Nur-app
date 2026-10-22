import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(12);

    Widget imageWidget;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoading();
        },
      );
    } else if (imageUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0ECE4),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: AppColors.primary.withValues(alpha: 0.3),
          size: (height != null && height! < 80) ? 24 : 36,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3EFE9),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
