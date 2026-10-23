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
    return CustomScrollView(
      slivers: [
        // Header (App Bar)
        SliverToBoxAdapter(
          child: HomeHeader(
            cartCount: homeState.cartCount,
            hasUnreadNotifications: homeState.hasUnreadNotifications,
            onCartTap: widget.onOpenCart,
            onNotificationTap: widget.onOpenNotifications,
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
}
