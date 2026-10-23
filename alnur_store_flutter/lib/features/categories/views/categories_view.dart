import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alnur_store_client/alnur_store_client.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../../shared/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/controllers/home_controller.dart';

class CategoriesView extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  final VoidCallback? onBackToHome;
  final VoidCallback? onOpenAiChat;

  const CategoriesView({
    super.key,
    this.initialCategoryId,
    this.onBackToHome,
    this.onOpenAiChat,
  });

  @override
  ConsumerState<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends ConsumerState<CategoriesView> {
  String _selectedCategory = 'all';
  String _searchFilter = '';
  String _selectedSort = 'featured';
  bool _isLoadingBackend = false;
  List<StoreCategory> _serverCategories = [];
  List<StoreProduct> _serverProducts = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryId ?? 'all';
    _fetchServerpodData();
  }

  Future<void> _fetchServerpodData() async {
    setState(() => _isLoadingBackend = true);
    try {
      final fetchedCategories = await client.category.getCategories();
      final fetchedProducts = await client.product.getProducts();

      if (mounted) {
        setState(() {
          _serverCategories = fetchedCategories;
          _serverProducts = fetchedProducts;
          _isLoadingBackend = false;
        });
      }
    } catch (e) {
      // Graceful fallback to local Riverpod state if Serverpod is starting up or offline
      debugPrint('[CategoriesView] Serverpod sync notice: $e');
      if (mounted) {
        setState(() => _isLoadingBackend = false);
      }
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'abayas':
        return Icons.dry_cleaning_rounded;
      case 'hijabs':
        return Icons.all_inclusive_rounded;
      case 'jalabias':
        return Icons.auto_awesome_outlined;
      case 'thobes':
        return Icons.person_rounded;
      case 'perfumes':
        return Icons.spa_rounded;
      case 'jewelries':
        return Icons.diamond_outlined;
      case 'bags':
        return Icons.shopping_bag_outlined;
      case 'slippers':
        return Icons.hiking_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);
    final cartCount = ref.watch(cartControllerProvider).totalCount;

    // Sync with homeState.selectedCategoryId if changed from outside (e.g. Home tab)
    ref.listen<HomeState>(homeControllerProvider, (prev, next) {
      if (next.selectedCategoryId != null && next.selectedCategoryId != _selectedCategory) {
        setState(() {
          _selectedCategory = next.selectedCategoryId!;
        });
      }
    });

    // Merge categories: use Serverpod categories if available, otherwise fallback to homeState
    final List<Map<String, dynamic>> categoryTabs = [
      {'id': 'all', 'label': 'All Modest Wear', 'icon': Icons.all_inclusive_rounded},
    ];

    if (_serverCategories.isNotEmpty) {
      for (final sc in _serverCategories) {
        final cid = sc.categoryId.toLowerCase();
        if (cid == 'perfumes' || cid == 'jewelries' || cid == 'accessories' || cid == 'slippers') continue;
        categoryTabs.add({
          'id': sc.categoryId,
          'label': sc.name,
          'icon': _getCategoryIcon(sc.categoryId),
        });
      }
    } else {
      for (final c in homeState.categories) {
        categoryTabs.add({
          'id': c.id,
          'label': c.name,
          'icon': c.fallbackIcon,
        });
      }
    }

    // Merge products: prioritize Serverpod backend products, fallback to homeState
    List<ProductModel> allProducts = [];
    if (_serverProducts.isNotEmpty) {
      allProducts = _serverProducts
          .where((sp) {
            final cid = sp.categoryId.toLowerCase();
            return cid != 'perfumes' && cid != 'jewelries' && cid != 'accessories' && cid != 'slippers';
          })
          .map(
            (sp) => ProductModel(
              id: (sp.id ?? sp.slug).toString(),
              name: sp.name,
              price: sp.price,
              originalPrice: sp.originalPrice,
              rating: sp.rating,
              reviewCount: sp.reviewCount,
              imageUrl: sp.imageUrl,
              categoryId: sp.categoryId,
              isFavorite: sp.isFavorite ?? false,
              description: sp.description,
            ),
          )
          .toList();
    } else {
      final productMap = <String, ProductModel>{};
      for (final p in [
        ...homeState.featuredProducts,
        ...homeState.abayasProducts,
        ...homeState.hijabsProducts,
        ...homeState.jalabiasProducts,
        ...homeState.thobesProducts,
      ]) {
        productMap[p.id] = p;
      }
      allProducts = productMap.values.toList();
    }

    // Filter by category
    List<ProductModel> displayedProducts = _selectedCategory == 'all'
        ? allProducts
        : allProducts.where((p) => p.categoryId == _selectedCategory).toList();

    // Filter by search query
    if (_searchFilter.isNotEmpty) {
      displayedProducts = displayedProducts
          .where((p) =>
              p.name.toLowerCase().contains(_searchFilter.toLowerCase()) ||
              p.description.toLowerCase().contains(_searchFilter.toLowerCase()) ||
              p.categoryId.toLowerCase().contains(_searchFilter.toLowerCase()))
          .toList();
    }

    // Sort products
    if (_selectedSort == 'price_low') {
      displayedProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'price_high') {
      displayedProducts.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedSort == 'rating') {
      displayedProducts.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: widget.onBackToHome != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
                onPressed: widget.onBackToHome,
                tooltip: 'Back to Home',
              )
            : null,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Modest Collections',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        actions: [
          if (_isLoadingBackend)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Sync with Serverpod',
            onPressed: _fetchServerpodData,
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: AppColors.primary),
            tooltip: 'Sort Collections',
            onPressed: () => _showSortModal(),
          ),
          // Shopping Bag / Cart Action Button with Badge
          GestureDetector(
            onTap: () => context.push(AppRoutes.cart),
            child: Padding(
              padding: const EdgeInsets.only(right: 14, left: 4),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Center(
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (val) => setState(() => _searchFilter = val),
              decoration: InputDecoration(
                hintText: 'Search abayas, hijabs, jalabias, perfumes...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                suffixIcon: _searchFilter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchFilter = ''),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Horizontal Category Selector Chips
          Container(
            color: Colors.white,
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categoryTabs.length,
              itemBuilder: (context, index) {
                final tab = categoryTabs[index];
                final isSelected = _selectedCategory == tab['id'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: FilterChip(
                    avatar: Icon(
                      tab['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    label: Text(tab['label'] as String),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceMuted.withValues(alpha: 0.6),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    onSelected: (val) {
                      final selectedId = tab['id'] as String;
                      setState(() => _selectedCategory = selectedId);
                      // Sync with global homeController
                      if (selectedId != 'all') {
                        final matchedCat = homeState.categories
                            .where((c) => c.id == selectedId)
                            .firstOrNull;
                        if (matchedCat != null) {
                          homeController.selectCategory(matchedCat);
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Product count & sort indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${displayedProducts.length} Modest Items Found',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_serverProducts.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.cloud_done_rounded, size: 10, color: AppColors.primary),
                            SizedBox(width: 3),
                            Text(
                              'Serverpod Live',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                GestureDetector(
                  onTap: () => _showSortModal(),
                  child: Row(
                    children: [
                      Text(
                        _getSortLabel(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchServerpodData,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: displayedProducts.isEmpty
                  ? LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
                                const SizedBox(height: 12),
                                const Text(
                                  'No modest dressings matched your search',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedCategory = 'all';
                                      _searchFilter = '';
                                    });
                                  },
                                  child: const Text('Reset All Filters', style: TextStyle(color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.64,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: displayedProducts.length,
                      itemBuilder: (context, index) {
                        final product = displayedProducts[index];
                        return _buildProductCard(context, product, homeController);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product, HomeController homeController) {
    return GestureDetector(
      onTap: () => _showProductDetailsModal(context, product, homeController),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primaryContainer,
                          child: const Center(
                            child: Icon(Icons.checkroom, color: AppColors.primary, size: 36),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        homeController.toggleFavorite(product);
                        // Also sync to Serverpod if ID is numeric
                        final intId = int.tryParse(product.id);
                        if (intId != null) {
                          try {
                            await client.product.toggleFavorite(intId);
                          } catch (_) {}
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                product.isFavorite
                                    ? 'Removed ${product.name} from favorites'
                                    : 'Added ${product.name} to favorites!',
                              ),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: product.isFavorite ? Colors.red : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Category Badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.categoryId.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.starAmber),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price & Add to Bag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₦${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          if (product.originalPrice != null)
                            Text(
                              '₦${product.originalPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(cartControllerProvider.notifier).addItem(product);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.name} to bag!'),
                              backgroundColor: AppColors.primary,
                              duration: const Duration(seconds: 3),
                              action: SnackBarAction(
                                label: 'VIEW BAG',
                                textColor: AppColors.gold,
                                onPressed: () => context.push(AppRoutes.cart),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 15),
                        ),
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

  void _showProductDetailsModal(BuildContext context, ProductModel product, HomeController homeController) {
    String selectedSize = '56';
    final sizes = ['52', '54', '56', '58', '60'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Top
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      product.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  if (widget.onOpenAiChat != null)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onOpenAiChat!();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Ask AI Stylist',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Content Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppTextStyles.productTitle.copyWith(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '₦${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.starAmber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating} Rating (${product.reviewCount} reviews)',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Text(
                            '100% Halal Fabric',
                            style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Select Modest Length / Size:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: sizes.map((s) {
                            final isSelected = selectedSize == s;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text('Size $s'),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                onSelected: (_) => setModalState(() => selectedSize = s),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Artisanal Description:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Guaranteed full opaque coverage, non-transparent weave with gift box & Oud scenting.',
                                style: TextStyle(fontSize: 11, color: AppColors.primaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Buy Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: Text(
                      'Add to Bag (Size $selectedSize) • ₦${product.price.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    onPressed: () {
                      ref.read(cartControllerProvider.notifier).addItem(
                            product,
                            size: selectedSize,
                          );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${product.name} (Size $selectedSize) to bag!'),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'VIEW BAG',
                            textColor: AppColors.gold,
                            onPressed: () => context.push(AppRoutes.cart),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort Collections By', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Featured & Best Selling'),
              trailing: _selectedSort == 'featured' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _selectedSort = 'featured');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Price: Low to High'),
              trailing: _selectedSort == 'price_low' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _selectedSort = 'price_low');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Price: High to Low'),
              trailing: _selectedSort == 'price_high' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _selectedSort = 'price_high');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Highest Customer Rating (4.8+)'),
              trailing: _selectedSort == 'rating' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _selectedSort = 'rating');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel() {
    switch (_selectedSort) {
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'rating':
        return 'Top Rated';
      default:
        return 'Sort: Featured';
    }
  }
}
