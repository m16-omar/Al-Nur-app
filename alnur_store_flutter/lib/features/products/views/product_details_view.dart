import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/product_image.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../models/product_review.dart';
import '../repositories/review_repository.dart';
import '../widgets/write_review_dialog.dart';

class ProductDetailsView extends ConsumerStatefulWidget {
  final String productId;
  final ProductModel? initialProduct;

  const ProductDetailsView({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  ConsumerState<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends ConsumerState<ProductDetailsView> {
  int _selectedImageIndex = 0;
  String _selectedSize = '56';
  String _selectedColor = 'Midnight Black';
  int _quantity = 1;

  final List<Map<String, dynamic>> _colorSwatches = [
    {'name': 'Midnight Black', 'color': const Color(0xFF18181B)},
    {'name': 'Royal Emerald', 'color': const Color(0xFF064E3B)},
    {'name': 'Desert Gold', 'color': const Color(0xFFD97706)},
    {'name': 'Medina Ivory', 'color': const Color(0xFFF4EFE6)},
    {'name': 'Deep Burgundy', 'color': const Color(0xFF831843)},
  ];

  final List<String> _sizes = ['50', '52', '54', '56', '58', '60', '62'];

  List<ProductReview> _reviews = [];
  bool _isLoadingReviews = true;
  int _additionalReviewCount = 0;
  String? _loadedProductId;

  void _ensureReviewsLoaded(ProductModel product) {
    if (_loadedProductId == product.id) return;
    _loadedProductId = product.id;
    ReviewRepository.getReviews(
      productId: product.id,
      categoryId: product.categoryId,
      productName: product.name,
    ).then((list) {
      if (mounted) {
        setState(() {
          _reviews = list;
          _isLoadingReviews = false;
        });
      }
    });
  }

  void _openWriteReviewForm(ProductModel product) async {
    final authUser = ref.read(authControllerProvider).user;
    await WriteReviewDialog.show(
      context,
      productId: product.id,
      productName: product.name,
      productImageUrl: product.imageUrl,
      initialUserName: authUser?.name,
      onReviewSubmitted: (newRev) {
        setState(() {
          _reviews.insert(0, newRev);
          _additionalReviewCount++;
        });
      },
    );
  }

  ProductModel _resolveProduct(HomeState homeState) {
    if (widget.initialProduct != null) {
      // Find updated state version to keep favorite sync
      return homeState.allProducts.firstWhere(
        (p) => p.id == widget.initialProduct!.id,
        orElse: () => widget.initialProduct!,
      );
    }

    return homeState.allProducts.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => widget.initialProduct ?? (homeState.allProducts.isNotEmpty ? homeState.allProducts.first : ProductModel(
        id: widget.productId,
        name: 'Al-Nur Modest Item',
        price: 32000,
        originalPrice: 38000,
        rating: 4.9,
        reviewCount: 48,
        imageUrl: '',
        categoryId: 'perfumes',
        description: 'Authentic modest luxury from the Al-Nur collection.',
      )),
    );
  }

  void _shareProduct(ProductModel product) {
    final link = 'https://alnur.store/product/${product.id}';
    Clipboard.setData(ClipboardData(text: '$link • ${product.name} - ${CurrencyFormatter.format(product.price)}'));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product link copied to clipboard! Share the modesty couture look.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSizeGuideModal() {
    int heightFeet = 5;
    int heightInches = 6;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          int recommendedSize = 52 + ((heightFeet * 12 + heightInches - 60) ~/ 2) * 2;
          if (recommendedSize < 50) recommendedSize = 50;
          if (recommendedSize > 62) recommendedSize = 62;

          return Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Abaya & Thobe Size Guide', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const Text(
                  'Select your height to calculate your ideal modest floor-grazing length.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Feet selector
                    Column(
                      children: [
                        const Text('Feet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [4, 5, 6].map((f) {
                            final isSel = heightFeet == f;
                            return GestureDetector(
                              onTap: () => setModalState(() => heightFeet = f),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.primary : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "$f'",
                                  style: TextStyle(
                                    color: isSel ? Colors.white : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Inches selector
                    Column(
                      children: [
                        const Text('Inches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<int>(
                            value: heightInches,
                            underline: const SizedBox.shrink(),
                            items: List.generate(12, (i) => i).map((i) {
                              return DropdownMenuItem(value: i, child: Text('$i"'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => heightInches = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.checkroom_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommended Size: $recommendedSize',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Perfect floor grazing drape for $heightFeet\' $heightInches" height.',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() => _selectedSize = '$recommendedSize');
                      Navigator.pop(modalCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected Size $recommendedSize!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: Text('Select Size $recommendedSize'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openImageZoom(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);
    final product = _resolveProduct(homeState);
    _ensureReviewsLoaded(product);

    // Multi-angle gallery images based on primary product image
    final galleryImages = [
      if (product.imageUrl.isNotEmpty) product.imageUrl,
    ];
    if (galleryImages.isEmpty) {
      galleryImages.add('');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Top App Bar with Image Carousel & Pinch Zoom
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      // Image Carousel
                      SizedBox(
                        height: 390,
                        child: PageView.builder(
                          itemCount: galleryImages.length,
                          onPageChanged: (idx) => setState(() => _selectedImageIndex = idx),
                          itemBuilder: (ctx, i) {
                            final imgUrl = galleryImages[i];
                            return GestureDetector(
                              onTap: () => _openImageZoom(imgUrl),
                              child: Hero(
                                tag: i == 0 ? 'product_${product.id}' : 'product_gallery_$i',
                                child: ProductImage(
                                  imageUrl: imgUrl,
                                  width: double.infinity,
                                  height: 390,
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Floating Top Controls (Back, Share, Favorite)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.home);
                                }
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _shareProduct(product),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => homeController.toggleFavorite(product),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: product.isFavorite ? AppColors.notificationRed : AppColors.textPrimary,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Carousel Page Indicator Pill
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(galleryImages.length, (idx) {
                                final isCur = idx == _selectedImageIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: isCur ? 16 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isCur ? Colors.white : Colors.white54,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product Information & Details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Pill & Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.categoryId.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _openWriteReviewForm(product),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 18, color: AppColors.starAmber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${product.rating.toStringAsFixed(1)} (${product.reviewCount + _additionalReviewCount} reviews)',
                                      style: AppTextStyles.productRating.copyWith(fontSize: 13),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.rate_review_outlined, size: 14, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          product.name,
                          style: AppTextStyles.productTitle.copyWith(fontSize: 22, height: 1.25),
                        ),
                        const SizedBox(height: 10),

                        // Price & Discount
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              CurrencyFormatter.format(product.price),
                              style: AppTextStyles.productPrice.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                            if (product.originalPrice != null && product.originalPrice! > product.price) ...[
                              const SizedBox(width: 10),
                              Text(
                                CurrencyFormatter.format(product.originalPrice!),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentMint.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'SAVE ${(100 - (product.price / product.originalPrice! * 100)).round()}%',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 18),

                        // Modesty Features Badges
                        Row(
                          children: [
                            _buildModestyFeatureBadge(Icons.shield_outlined, '100% Opaque'),
                            const SizedBox(width: 8),
                            _buildModestyFeatureBadge(Icons.air_rounded, 'Breathable'),
                            const SizedBox(width: 8),
                            _buildModestyFeatureBadge(Icons.handyman_outlined, 'Master Tailored'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Color Selection Swatches
                        Text('Color: $_selectedColor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 10),
                        Row(
                          children: _colorSwatches.map((item) {
                            final name = item['name'] as String;
                            final color = item['color'] as Color;
                            final isSelected = _selectedColor == name;

                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = name),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: color == const Color(0xFFF4EFE6) ? Colors.black : Colors.white,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Size Selection & Size Guide
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Modesty Length / Size: $_selectedSize',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            GestureDetector(
                              onTap: _openSizeGuideModal,
                              child: const Row(
                                children: [
                                  Icon(Icons.straighten_rounded, size: 14, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Size Calculator',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _sizes.map((s) {
                            final isSel = _selectedSize == s;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = s),
                              child: Container(
                                width: 50,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSel ? AppColors.primary : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSel ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Description
                        const Text('Description & Fabric Care',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        Text(
                          product.description.isNotEmpty
                              ? product.description
                              : 'Expertly draped using high-density Medina crepe, designed to be completely non-transparent and gracefully flow past ankles. Perfect for Jum’ah prayer, weddings, or refined daily wear.',
                          style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 18),

                        // Customer Reviews Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Verified Client Reviews',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 16, color: AppColors.starAmber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.9 (${product.reviewCount + _additionalReviewCount} reviews)',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: AppColors.primaryLight, width: 1),
                                ),
                              ),
                              icon: const Icon(Icons.rate_review_outlined, size: 16),
                              label: const Text(
                                'Write Review',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              onPressed: () => _openWriteReviewForm(product),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Rating Summary Card with CTA
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    '4.9',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                      height: 1.1,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => const Icon(Icons.star_rounded, size: 14, color: AppColors.starAmber),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${product.reviewCount + _additionalReviewCount} ratings',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Container(width: 1, height: 48, color: AppColors.border),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Have you experienced this piece?',
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Help fellow patrons choose authentic modest luxury.',
                                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () => _openWriteReviewForm(product),
                                      child: const Text(
                                        '★ Tap to rate & leave feedback →',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dynamic Review List
                        if (_isLoadingReviews)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              ),
                            ),
                          )
                        else if (_reviews.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.star_outline_rounded, size: 36, color: AppColors.primary),
                                const SizedBox(height: 8),
                                const Text(
                                  'Be the First to Review',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Share your honest thoughts about the modest drape, craftsmanship, and fit.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _openWriteReviewForm(product),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  child: const Text('Write First Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: _reviews.map((rev) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildReviewCard(rev),
                            )).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Bottom Purchase Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          ),
                          Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Add to Bag Button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: const Text('Add to Bag', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        onPressed: () {
                          ref.read(cartControllerProvider.notifier).addItem(
                                product,
                                size: _selectedSize,
                                color: _selectedColor,
                                quantity: _quantity,
                              );
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $_quantity × ${product.name} (Size $_selectedSize) to bag!'),
                              backgroundColor: AppColors.primary,
                              action: SnackBarAction(
                                label: 'View Bag',
                                textColor: AppColors.goldLight,
                                onPressed: () => context.push(AppRoutes.cart),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Buy Now Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ref.read(cartControllerProvider.notifier).addItem(
                              product,
                              size: _selectedSize,
                              color: _selectedColor,
                              quantity: _quantity,
                            );
                        context.push(AppRoutes.cart);
                      },
                      child: const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModestyFeatureBadge(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ProductReview review) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  review.userInitial,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.isVerifiedBuyer) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: AppColors.accentGreen),
                          const SizedBox(width: 2),
                          const Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGreen,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      review.date,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < review.rating.round() ? AppColors.starAmber : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          if (review.title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: review.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
