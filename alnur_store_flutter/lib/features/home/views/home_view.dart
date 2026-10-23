import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../ai_assistant/views/ai_chat_view.dart';
import '../../authentication/controllers/auth_controller.dart';
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
              cartCount: homeState.cartCount,
              hasUnreadNotifications: homeState.hasUnreadNotifications,
              onCartTap: widget.onOpenCart ?? () => _showCartModal(context, homeState, homeController),
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
            onProductTap: (product) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected ${product.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
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
            onProductTap: (product) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected ${product.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
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
            onProductTap: (product) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected ${product.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
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
            onProductTap: (product) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected ${product.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
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
            onProductTap: (product) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected ${product.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
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

  void _showCartModal(BuildContext context, HomeState homeState, HomeController homeController) {
    int dubaiQty = 1;
    int medinaQty = 2;
    int jalabiaQty = 1;
    bool promoApplied = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final subtotal = (dubaiQty * 28500) + (medinaQty * 8500) + (jalabiaQty * 32000);
            final discount = promoApplied ? (subtotal * 0.15).round() : 0;
            const shipping = 2500;
            final grandTotal = subtotal - discount + shipping;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                            Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Modest Shopping Bag',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      children: [
                        if (dubaiQty > 0)
                          _buildCartCard(
                            title: 'Dubai Gold Noir Abaya',
                            subtitle: 'Size 56 • Midnight Black / Gold',
                            price: 28500,
                            qty: dubaiQty,
                            imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=500&q=80',
                            onIncrement: () => setModalState(() => dubaiQty++),
                            onDecrement: () => setModalState(() => dubaiQty--),
                          ),
                        if (medinaQty > 0)
                          _buildCartCard(
                            title: 'Pure Medina Silk Hijab',
                            subtitle: 'Standard (180x75cm) • Emerald Silk',
                            price: 8500,
                            qty: medinaQty,
                            imageUrl: 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&w=500&q=80',
                            onIncrement: () => setModalState(() => medinaQty++),
                            onDecrement: () => setModalState(() => medinaQty--),
                          ),
                        if (jalabiaQty > 0)
                          _buildCartCard(
                            title: 'Royal Emerald Velvet Jalabia',
                            subtitle: 'Size 58 • Deep Emerald / Gold Thread',
                            price: 32000,
                            qty: jalabiaQty,
                            imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=500&q=80',
                            onIncrement: () => setModalState(() => jalabiaQty++),
                            onDecrement: () => setModalState(() => jalabiaQty--),
                          ),

                        const SizedBox(height: 12),

                        // Promo voucher applied pill
                        GestureDetector(
                          onTap: () => setModalState(() => promoApplied = !promoApplied),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: promoApplied ? const Color(0xFFFBF4E6) : AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: promoApplied ? AppColors.gold.withValues(alpha: 0.6) : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  promoApplied ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: promoApplied ? AppColors.goldDark : AppColors.textSecondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    promoApplied
                                        ? 'Promo Code ALNUR15 applied (15% Modesty Savings)'
                                        : 'Tap to apply promo code ALNUR15 (15% OFF)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: promoApplied ? AppColors.goldDark : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                if (promoApplied)
                                  Text(
                                    '-₦${discount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.goldDark,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Bill breakdown
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildCostRow('Subtotal', '₦${subtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
                              const SizedBox(height: 8),
                              _buildCostRow('Modesty Voucher Discount (15%)', '-₦${discount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', isGreen: true),
                              const SizedBox(height: 8),
                              _buildCostRow('Express Halal Delivery (Lagos & Nationwide)', '₦2,500'),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(height: 1, color: AppColors.border),
                              ),
                              _buildCostRow('Estimated Total', '₦${grandTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', isBold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Checkout Action
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCheckoutSuccessDialog(grandTotal);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Proceed to Halal Checkout • ₦${grandTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildCartCard({
    required String title,
    required String subtitle,
    required int price,
    required int qty,
    required String imageUrl,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 64,
                height: 64,
                color: AppColors.surfaceMuted,
                child: const Icon(Icons.dry_cleaning_rounded, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  '₦${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.textSecondary, size: 20),
                onPressed: onDecrement,
              ),
              Text(
                '$qty',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isGreen = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isGreen
                ? const Color(0xFF10B981)
                : (isBold ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  void _showCheckoutSuccessDialog(int totalAmount) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Alhamdulillah! Order Placed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Your modest attire order of ₦${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} has been confirmed. Sizing and quality verification in progress.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _currentNavIndex = 3); // Switch to Orders tab
                  },
                  child: const Text('View Order Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
