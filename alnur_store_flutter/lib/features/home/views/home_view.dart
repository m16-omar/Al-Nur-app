import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import '../widgets/ai_assistant_banner.dart';
import '../widgets/category_section.dart';
import '../widgets/featured_products.dart';
import '../widgets/hero_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';

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
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final homeController = ref.read(homeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
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

                // Hero Banner
                SliverToBoxAdapter(
                  child: HeroBanner(
                    onShopNowTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigating to New Arrivals...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),

                // Category Section
                SliverToBoxAdapter(
                  child: CategorySection(
                    categories: homeState.categories,
                    selectedCategoryId: homeState.selectedCategoryId,
                    onCategorySelected: (cat) => homeController.selectCategory(cat),
                  ),
                ),

                // AI Assistant Banner
                SliverToBoxAdapter(
                  child: AiAssistantBanner(
                    onChatTap: widget.onOpenAiChat,
                  ),
                ),

                // Featured Products Section
                SliverToBoxAdapter(
                  child: FeaturedProductsSection(
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
                    onViewAllTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viewing all featured products'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Padding for floating nav bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 110),
                ),
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
    return GestureDetector(
      onTap: widget.onOpenAiChat,
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
            child: const Text(
              'AI Assistant',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
