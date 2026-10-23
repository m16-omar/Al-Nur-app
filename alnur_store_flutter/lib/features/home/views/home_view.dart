import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/product_model.dart';
import '../../ai_assistant/views/ai_chat_view.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../categories/views/categories_view.dart';
import '../../orders/views/orders_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/home_controller.dart';
import '../widgets/ai_assistant_banner.dart';
import '../widgets/category_section.dart';
import '../widgets/featured_products.dart';
import '../widgets/hero_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/welcome_user_dialog.dart';

class HomeView extends ConsumerStatefulWidget {
  final VoidCallback? onOpenAiChat;
  final VoidCallback? onOpenCart;
  final VoidCallback? onOpenNotifications;

  const HomeView({
    super.key,
    this.onOpenAiChat,
    this.onOpenCart,
    this.onOpenNotifications,
  });

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWelcomePopup();
    });
  }

  void _checkWelcomePopup() {
    final authState = ref.read(authControllerProvider);
    if (authState.shouldShowWelcomePopup) {
      ref.read(authControllerProvider.notifier).dismissWelcomePopup();
      _openWelcomeDialog(authState.user?.name);
    }
  }

  void _openWelcomeDialog([String? name]) {
    WelcomeUserDialog.show(
      context,
      userName: name ?? ref.read(authControllerProvider).user?.name ?? 'Valued Guest',
      onStartShopping: () {
        setState(() => _currentNavIndex = 1);
      },
      onOpenAiStylist: () {
        setState(() => _currentNavIndex = 2);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);

    // Listen for runtime login events that trigger the welcome modal
    ref.listen(authControllerProvider, (prev, next) {
      if (next.shouldShowWelcomePopup && mounted) {
        ref.read(authControllerProvider.notifier).dismissWelcomePopup();
        _openWelcomeDialog(next.user?.name);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Active Tab View via IndexedStack
            IndexedStack(
              index: _currentNavIndex,
              children: [
                _buildHomeContent(homeState, homeController, authState.user?.name),
                CategoriesView(
                  onBackToHome: () => setState(() => _currentNavIndex = 0),
                  onOpenAiChat: () => setState(() => _currentNavIndex = 2),
                ),
                const AiChatView(isEmbeddedTab: true),
                OrdersView(onBackToHome: () => setState(() => _currentNavIndex = 0)),
                ProfileView(onNavigateToOrders: () => setState(() => _currentNavIndex = 3)),
              ],
            ),

            // Floating Bottom Navigation Bar
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: _buildFloatingNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(HomeState homeState, HomeController homeController, String? userName) {
    return RefreshIndicator(
      onRefresh: () => homeController.refreshHomeData(),
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // Header (App Bar)
          SliverToBoxAdapter(
            child: HomeHeader(
              cartCount: ref.watch(cartControllerProvider).totalCount,
              hasUnreadNotifications: homeState.hasUnreadNotifications,
              onCartTap: widget.onOpenCart ?? () => _showCartModal(context),
              onNotificationTap: widget.onOpenNotifications ?? () => _showNotificationsModal(context),
            ),
          ),

        // Search Bar
        SliverToBoxAdapter(
          child: SearchBarWidget(
            onChanged: (val) => homeController.updateSearchQuery(val),
            onVoiceTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listening for voice search...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),

        // Welcome Gift Voucher Pill Banner
        SliverToBoxAdapter(
          child: _buildWelcomeVoucherBanner(userName),
        ),

        // Hero Banner
        SliverToBoxAdapter(
          child: HeroBanner(
            onShopNowTap: () {
              setState(() => _currentNavIndex = 1);
            },
          ),
        ),

        // Category Section
        SliverToBoxAdapter(
          child: CategorySection(
            categories: homeState.categories,
            selectedCategoryId: homeState.selectedCategoryId,
            onCategorySelected: (cat) {
              homeController.selectCategory(cat);
              setState(() => _currentNavIndex = 1);
            },
          ),
        ),

        // AI Assistant Banner
        SliverToBoxAdapter(
          child: AiAssistantBanner(
            onChatTap: () => setState(() => _currentNavIndex = 2),
          ),
        ),

        // Featured Products Section
        SliverToBoxAdapter(
          child: FeaturedProductsSection(
            title: 'Featured Products',
            products: homeState.featuredProducts,
            onProductTap: (product) => _showProductDetailsModal(context, product),
            onFavoriteToggle: (product) => homeController.toggleFavorite(product),
            onViewAllTap: () => setState(() => _currentNavIndex = 1),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Al-Nur Abayas Section
        SliverToBoxAdapter(
          child: FeaturedProductsSection(
            title: 'Al-Nur Abayas',
            products: homeState.abayasProducts,
            onProductTap: (product) => _showProductDetailsModal(context, product),
            onFavoriteToggle: (product) => homeController.toggleFavorite(product),
            onViewAllTap: () => setState(() => _currentNavIndex = 1),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Al-Nur Hijabs Section
        SliverToBoxAdapter(
          child: FeaturedProductsSection(
            title: 'Al-Nur Hijabs',
            products: homeState.hijabsProducts,
            onProductTap: (product) => _showProductDetailsModal(context, product),
            onFavoriteToggle: (product) => homeController.toggleFavorite(product),
            onViewAllTap: () => setState(() => _currentNavIndex = 1),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Al-Nur Jalabias Section
        SliverToBoxAdapter(
          child: FeaturedProductsSection(
            title: 'Al-Nur Jalabias',
            products: homeState.jalabiasProducts,
            onProductTap: (product) => _showProductDetailsModal(context, product),
            onFavoriteToggle: (product) => homeController.toggleFavorite(product),
            onViewAllTap: () => setState(() => _currentNavIndex = 1),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Al-Nur Thobes & Jubbahs Section
        SliverToBoxAdapter(
          child: FeaturedProductsSection(
            title: 'Al-Nur Thobes & Jubbahs',
            products: homeState.thobesProducts,
            onProductTap: (product) => _showProductDetailsModal(context, product),
            onFavoriteToggle: (product) => homeController.toggleFavorite(product),
            onViewAllTap: () => setState(() => _currentNavIndex = 1),
          ),
        ),

        // Bottom Padding for floating nav bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 110),
        ),
      ],
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.grid_view_rounded, 'Categories'),
          _buildCenterAiItem(),
          _buildNavItem(3, Icons.inventory_2_outlined, 'Orders'),
          _buildNavItem(4, Icons.person_outline_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentNavIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterAiItem() {
    final isSelected = _currentNavIndex == 2;
    return GestureDetector(
      onTap: () {
        setState(() => _currentNavIndex = 2);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -10),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isSelected ? Border.all(color: AppColors.gold, width: 2) : null,
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -6),
            child: Text(
              'AI Assistant',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeVoucherBanner(String? userName) {
    return GestureDetector(
      onTap: () => _openWelcomeDialog(userName),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFBF4E6), Color(0xFFF5EFE6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_giftcard_rounded, color: AppColors.goldDark, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'NEW USER WELCOME GIFT',
                        style: TextStyle(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '15% OFF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to claim your ALNUR15 voucher & member perks',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.goldDark),
          ],
        ),
      ),
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Al-Nur Notifications',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All notifications marked as read'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      children: [
                        _buildNotificationItem(
                          icon: Icons.auto_awesome_rounded,
                          iconColor: AppColors.goldDark,
                          title: 'New Ramadan Collection Dropped! 🌙',
                          subtitle: 'Hand-tailored Dubai Black Organza and Silk Hijabs are now available in limited quantities.',
                          time: '10m ago',
                          isUnread: true,
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() => _currentNavIndex = 1);
                          },
                        ),
                        _buildNotificationItem(
                          icon: Icons.local_shipping_outlined,
                          iconColor: AppColors.primary,
                          title: 'Order Dispatched #ALN-84920 🚚',
                          subtitle: 'Courier Driver Ibrahim is en route with your Dubai Gold Noir Abaya. Estimated 4:30 PM.',
                          time: '2h ago',
                          isUnread: true,
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() => _currentNavIndex = 3);
                          },
                        ),
                        _buildNotificationItem(
                          icon: Icons.mosque_outlined,
                          iconColor: const Color(0xFF10B981),
                          title: 'Jumuah Mubarak Discount! 🕌',
                          subtitle: 'Enjoy 15% off all Jalabias & Thobes plus free nationwide delivery with code JUMUAH15.',
                          time: 'Yesterday',
                          isUnread: false,
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() => _currentNavIndex = 1);
                          },
                        ),
                        _buildNotificationItem(
                          icon: Icons.card_giftcard_rounded,
                          iconColor: AppColors.primary,
                          title: 'Welcome Gift Voucher Ready 🎁',
                          subtitle: 'Your ₦5,000 welcome credit has been applied to your modest shopping wallet.',
                          time: '2 days ago',
                          isUnread: false,
                          onTap: () {
                            Navigator.pop(ctx);
                            _openWelcomeDialog(null);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.surfaceMuted.withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartModal(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  void _showProductDetailsModal(BuildContext context, ProductModel product) {
    String selectedSize = '56';
    String selectedColor = 'Default';
    final List<String> sizes = ['52', '54', '56', '58', '60'];
    final List<String> colors = ['Default', 'Black', 'Emerald', 'Gold', 'Burgundy'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header & Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      product.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 220,
                        color: AppColors.surfaceMuted,
                        child: const Icon(Icons.checkroom_rounded, size: 48, color: AppColors.primary),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(ctx),
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
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
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.starAmber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating} (${product.reviewCount} reviews)',
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
                      const SizedBox(height: 16),
                      const Text(
                        'Select Modest Length / Size:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (val) {
                                  if (val) setModalState(() => selectedSize = s);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select Color:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: colors.map((c) {
                            final isSelected = selectedColor == c;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(c),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (val) {
                                  if (val) setModalState(() => selectedColor = c);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.description.isNotEmpty
                            ? product.description
                            : 'Experience pure modest luxury crafted with precision, premium breathable textiles, and traditional Islamic styling tailored for daily comfort and celebration.',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              // Add to Bag Button
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
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    onPressed: () {
                      ref.read(cartControllerProvider.notifier).addItem(
                            product,
                            size: selectedSize,
                            color: selectedColor,
                          );
                      Navigator.pop(ctx);
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
}
