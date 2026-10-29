import 'dart:convert';
import 'package:alnur_store_client/alnur_store_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../onboarding/services/onboarding_preferences.dart';
import '../../cart/services/selar_payment_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../main.dart';

class ProfileView extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onOpenCart;
  final bool isStandalonePage;
  final bool initialOpenAddresses;

  const ProfileView({
    super.key,
    this.onNavigateToOrders,
    this.onOpenCart,
    this.isStandalonePage = false,
    this.initialOpenAddresses = false,
  });

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userAvatarUrl = '';
  String _userBio = '';
  String _selectedCurrency = 'NGN (₦)';
  bool _notificationsEnabled = true;
  bool _jumuahRemindersEnabled = true;
  List<UserAddress> _addresses = [];
  bool _isLoadingAddresses = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileAndAddresses();
      if (widget.initialOpenAddresses) {
        _showAddressesModal();
      }
    });
  }

  Future<void> _loadProfileAndAddresses() async {
    final authState = ref.read(authControllerProvider);
    final user = authState.user;
    if (user != null && !user.isGuest) {
      if (mounted) {
        setState(() {
          _userName = user.name;
          _userEmail = user.email;
          _userPhone = user.phone ?? '';
          _userAvatarUrl = user.avatarUrl ?? '';
          _userBio = user.bio ?? '';
          _selectedCurrency = user.preferredCurrency ?? 'NGN (₦)';
        });
      }
      await _loadAddresses();
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final cachedJson = await OnboardingPreferences.getCachedAddresses();
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final decoded = jsonDecode(cachedJson) as List;
        final list = decoded
            .map((item) => UserAddress.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        if (mounted && list.isNotEmpty) {
          setState(() {
            _addresses = list;
          });
        }
      }
    } catch (_) {}

    final authState = ref.read(authControllerProvider);
    final user = authState.user;
    if (user == null || user.isGuest || user.email.isEmpty) {
      return;
    }

    if (mounted) setState(() => _isLoadingAddresses = true);

    try {
      final serverList = await client.user.getAddresses(email: user.email);
      if (serverList.isNotEmpty) {
        if (mounted) {
          setState(() {
            _addresses = serverList;
          });
        }
        await _cacheAddresses(serverList);
      } else if (_addresses.isEmpty) {
        final seed1 = UserAddress(
          userEmail: user.email,
          title: 'Primary Residence (Lekki)',
          recipientName: user.name.isNotEmpty ? user.name : 'Al-Nur Member',
          phoneNumber: user.phone?.isNotEmpty == true ? user.phone! : '+234 803 987 6543',
          streetAddress: 'Plot 14, Admiralty Way, Lekki Phase 1',
          city: 'Lekki / Lagos Island',
          state: 'Lagos',
          country: 'Nigeria',
          postalCode: '105102',
          isDefault: true,
          additionalInstructions: 'Call at the security gate upon arrival',
        );
        final seed2 = UserAddress(
          userEmail: user.email,
          title: 'Abuja Office (FCT)',
          recipientName: user.name.isNotEmpty ? user.name : 'Al-Nur Member',
          phoneNumber: user.phone?.isNotEmpty == true ? user.phone! : '+234 802 111 2233',
          streetAddress: 'No. 8, Gana Street, Maitama',
          city: 'Abuja',
          state: 'Abuja FCT',
          country: 'Nigeria',
          postalCode: '900271',
          isDefault: false,
          additionalInstructions: 'Deliver to 2nd floor reception desk',
        );

        final s1 = await client.user.saveAddress(address: seed1);
        final s2 = await client.user.saveAddress(address: seed2);
        if (mounted) {
          setState(() {
            _addresses = [s1, s2];
          });
        }
        await _cacheAddresses(_addresses);
      }
    } catch (e) {
      debugPrint('Address sync error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddresses = false);
      }
    }
  }

  Future<void> _cacheAddresses(List<UserAddress> addresses) async {
    try {
      final jsonList = addresses.map((a) => a.toJson()).toList();
      await OnboardingPreferences.saveCachedAddresses(jsonEncode(jsonList));
    } catch (_) {}
  }

  void _navigateToCart() {
    if (widget.onOpenCart != null) {
      widget.onOpenCart!();
    } else {
      appRouter.push(AppRoutes.cart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final cartCount = cartState.totalCount;
    final user = authState.user;
    final isGuest = authState.isGuest;
    final isAuthenticated = authState.isAuthenticated;

    // Real user data when authenticated; empty when guest (no fake email or username)
    final displayName = isAuthenticated && user != null && user.name.isNotEmpty
        ? user.name
        : (isGuest ? '' : _userName);
    final displayEmail = isAuthenticated && user != null && user.email.isNotEmpty
        ? user.email
        : (isGuest ? '' : _userEmail);
    final displayPhone = isAuthenticated && user != null && user.phone != null && user.phone!.isNotEmpty
        ? user.phone!
        : _userPhone;
    final displayAvatar = isAuthenticated && user != null && user.avatarUrl != null && user.avatarUrl!.isNotEmpty
        ? user.avatarUrl!
        : _userAvatarUrl;
    final displayBio = isAuthenticated && user != null && user.bio != null && user.bio!.isNotEmpty
        ? user.bio!
        : _userBio;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: widget.isStandalonePage
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
              )
            : null,
        title: Text(
          'My Profile & Preferences',
          style: AppTextStyles.productTitle.copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text(
                '$cartCount',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.goldDark,
              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
            ),
            tooltip: 'My Shopping Bag',
            onPressed: _navigateToCart,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            tooltip: 'Settings',
            onPressed: isGuest
                ? () => _showGuestPrompt(
                      title: 'Account Settings',
                      message: 'Please sign in or create an account to access and manage your Al-Nur account settings.',
                    )
                : () => _showPreferencesModal(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (isGuest) ...[
                    // Elegant Guest Avatar
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryContainer,
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 42,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Guest Shopper',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign in to sync your bag, orders & modesty rewards',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.login),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.login_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Sign In / Register',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Authenticated User Avatar with Initials / Real Info
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () => _showEditProfileModal(displayName, displayEmail, displayPhone, displayAvatar, displayBio, _selectedCurrency),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primary,
                              child: displayAvatar.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        displayAvatar,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(displayName),
                                      ),
                                    )
                                  : _buildAvatarFallback(displayName),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showEditProfileModal(displayName, displayEmail, displayPhone, displayAvatar, displayBio, _selectedCurrency),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName.isNotEmpty ? displayName : 'Al-Nur Member',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (displayEmail.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        displayEmail,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                    if (displayBio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        displayBio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.goldDark,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Gold VIP Modesty Member',
                            style: TextStyle(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.shopping_bag_outlined,
                    count: '$cartCount',
                    label: 'Cart',
                    color: AppColors.primary,
                    onTap: _navigateToCart,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.inventory_2_outlined,
                    count: isGuest ? '0' : '12',
                    label: 'Orders',
                    color: AppColors.primaryDark,
                    onTap: isGuest
                        ? () => _showGuestPrompt(
                              title: 'Modesty Orders',
                              message: 'Sign in or create an account to view and track your modest fashion orders.',
                            )
                        : (widget.onNavigateToOrders ?? () => context.push(AppRoutes.orders)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.favorite_border_rounded,
                    count: isGuest ? '0' : '${ref.watch(homeControllerProvider).favoriteProducts.length}',
                    label: 'Favorites',
                    color: const Color(0xFFE11D48),
                    onTap: isGuest
                        ? () => _showGuestPrompt(
                              title: 'Modesty Wishlist',
                              message: 'Sign in or create an account to view and sync your favorited modest couture across all your devices.',
                            )
                        : () => _showWishlistModal(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.stars_rounded,
                    count: isGuest ? '0' : '3,450',
                    label: 'Al-Nur Pts',
                    color: AppColors.goldDark,
                    onTap: isGuest
                        ? () => _showGuestPrompt(
                              title: 'Al-Nur Loyalty Points',
                              message: 'Join Al-Nur Loyalty! Sign in to earn modesty points on every modest wear purchase.',
                            )
                        : () => _showPointsModal(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Section 1: Account & Details
            _buildSectionHeader('Account & Address'),
            _buildCardGroup([
              _buildListTile(
                icon: Icons.shopping_bag_outlined,
                title: 'My Shopping Bag (Cart)',
                subtitle: cartCount > 0
                    ? '$cartCount items reserved in your bag'
                    : 'View saved modest garments & checkout',
                trailingWidget: cartCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$cartCount items',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: _navigateToCart,
              ),
              _buildListTile(
                icon: Icons.person_outline_rounded,
                title: 'Personal Information',
                subtitle: isGuest
                    ? 'Sign in to save your personal details'
                    : (displayName.isNotEmpty ? '$displayName • ${displayPhone.isNotEmpty ? displayPhone : displayEmail}' : 'Name, phone number, bio & currency'),
                onTap: isGuest
                    ? () => _showGuestPrompt(
                          title: 'Personal Information',
                          message: 'Please sign in or create an account to save your name, contact phone, and custom modesty sizing.',
                        )
                    : () => _showEditProfileModal(displayName, displayEmail, displayPhone, displayAvatar, displayBio, _selectedCurrency),
              ),
              _buildListTile(
                icon: Icons.location_on_outlined,
                title: 'Saved Delivery Addresses',
                subtitle: isGuest
                    ? 'Sign in to save delivery addresses'
                    : (_addresses.isNotEmpty
                        ? '${_addresses.length} saved address${_addresses.length == 1 ? '' : 'es'} (Default: ${_addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first).title})'
                        : 'Add your home or office address'),
                trailingWidget: _addresses.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '${_addresses.length} saved',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: isGuest
                    ? () => _showGuestPrompt(
                          title: 'Delivery Addresses',
                          message: 'Please sign in to save your preferred delivery addresses for fast 1-tap checkout.',
                        )
                    : () => _showAddressesModal(),
              ),
              _buildListTile(
                icon: Icons.payment_outlined,
                title: 'Payment & Cards',
                subtitle: isGuest ? 'Sign in to manage payment methods' : 'Mastercard & Selar Halal Gateway',
                onTap: isGuest
                    ? () => _showGuestPrompt(
                          title: 'Payment & Cards',
                          message: 'Sign in or create an account to securely save and manage your payment methods.',
                        )
                    : () => _showPaymentModal(),
              ),
            ]),

            const SizedBox(height: 20),

            // Section 2: Modesty Customization
            _buildSectionHeader('Modesty Fit & Preferences'),
            _buildCardGroup([
              _buildListTile(
                icon: Icons.straighten_rounded,
                title: 'Abaya & Thobe Size Profile',
                subtitle: 'Calculate length based on your height',
                onTap: () => _showSizeCalculatorModal(),
              ),
              _buildSwitchTile(
                icon: Icons.mosque_outlined,
                title: 'Jumuah & Prayer Reminders',
                subtitle: 'Receive modest Friday Jumuah attire inspiration',
                value: _jumuahRemindersEnabled,
                onChanged: (val) => setState(() => _jumuahRemindersEnabled = val),
              ),
              _buildSwitchTile(
                icon: Icons.notifications_none_rounded,
                title: 'Order & Drop Alerts',
                subtitle: 'Notifications for new Abaya collections',
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ]),

            const SizedBox(height: 20),

            // Section 3: App & Legal
            _buildSectionHeader('Support & Ethics'),
            _buildCardGroup([
              _buildListTile(
                icon: Icons.currency_exchange_rounded,
                title: 'Store Currency',
                subtitle: _selectedCurrency,
                onTap: () => _showCurrencyPicker(),
              ),
              _buildListTile(
                icon: Icons.verified_user_outlined,
                title: '100% Halal & Ethical Sourcing',
                subtitle: 'Read our artisan pledge & fair-wage guarantee',
                onTap: () => _showEthicalPledgeModal(),
              ),
              _buildListTile(
                icon: Icons.headset_mic_outlined,
                title: 'Help Center & WhatsApp Concierge',
                subtitle: 'Direct line to our personal shopping team',
                onTap: () => _showConciergeModal(),
              ),
              _buildListTile(
                icon: Icons.auto_stories_outlined,
                title: 'Al-Nur Brand & Onboarding Story',
                subtitle: 'Replay the 3-step luxury modest experience',
                onTap: () => context.push(AppRoutes.onboarding),
              ),
              if (kDebugMode && !isGuest)
                _buildListTile(
                  icon: Icons.restart_alt_rounded,
                  title: 'Reset First-Time User Experience',
                  subtitle: 'Clear saved state to test initial onboarding',
                  onTap: () => _showResetOnboardingDialog(),
                ),
            ]),

            const SizedBox(height: 24),

            // Action Button (Sign In for Guest, Sign Out for Authenticated)
            SizedBox(
              width: double.infinity,
              child: isGuest
                  ? ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 1,
                      ),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text(
                        'Sign In or Create Account',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      onPressed: () => context.push(AppRoutes.login),
                    )
                  : OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: const Color(0xFFFEF2F2),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Sign Out of Al-Nur Store',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      onPressed: () => _showSignOutDialog(),
                    ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              count,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          final isLast = index == children.length - 1;
          return Column(
            children: [
              children[index],
              if (!isLast) const Divider(height: 1, indent: 56, color: AppColors.border),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingWidget != null) ...[
            trailingWidget,
            const SizedBox(width: 6),
          ],
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  void _showGuestPrompt({required String title, required String message}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Stay as Guest', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(AppRoutes.login);
                    },
                    child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    return Text(
      initial,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showEditProfileModal(
    String currentName,
    String currentEmail,
    String currentPhone,
    String currentAvatar,
    String currentBio,
    String currentCurrency,
  ) {
    final nameCtrl = TextEditingController(text: currentName);
    final emailCtrl = TextEditingController(text: currentEmail);
    final phoneCtrl = TextEditingController(text: currentPhone);
    final avatarCtrl = TextEditingController(text: currentAvatar);
    final bioCtrl = TextEditingController(text: currentBio);
    String selectedCurrency = currentCurrency.isNotEmpty ? currentCurrency : 'NGN';
    String previewAvatar = currentAvatar;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(modalCtx).viewInsets.bottom),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
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
                      children: [
                        const Icon(Icons.badge_outlined, color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Text('Edit Account Information', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Avatar Preview
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.primary,
                              child: previewAvatar.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        previewAvatar,
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(currentName),
                                      ),
                                    )
                                  : _buildAvatarFallback(currentName),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Profile Photo / Avatar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                        border: OutlineInputBorder(),
                        helperText: 'Account identification email',
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                        border: OutlineInputBorder(),
                        hintText: '+234 803 123 4567',
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: avatarCtrl,
                      onChanged: (val) {
                        setModalState(() {
                          previewAvatar = val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Avatar Image URL (Cloudflare R2 or Web link)',
                        prefixIcon: const Icon(Icons.image_outlined, color: AppColors.primary),
                        border: const OutlineInputBorder(),
                        hintText: 'https://...',
                        suffixIcon: previewAvatar.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  avatarCtrl.clear();
                                  setModalState(() => previewAvatar = '');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: bioCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Modesty Profile & Sizing Notes',
                        prefixIcon: Icon(Icons.straighten_rounded, color: AppColors.primary),
                        border: OutlineInputBorder(),
                        hintText: 'e.g. Standard Abaya Size 56, prefers chiffon hijabs',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Currency Selector
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Preferred Store Currency',
                        prefixIcon: Icon(Icons.currency_exchange_rounded, color: AppColors.primary),
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCurrency.contains('USD') ? 'USD' : (selectedCurrency.contains('GBP') ? 'GBP' : (selectedCurrency.contains('SAR') ? 'SAR' : (selectedCurrency.contains('EUR') ? 'EUR' : (selectedCurrency.contains('AED') ? 'AED' : 'NGN')))),
                          isDense: true,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'NGN', child: Text('NGN (₦) - Nigerian Naira')),
                            DropdownMenuItem(value: 'USD', child: Text('USD (\$) - US Dollar')),
                            DropdownMenuItem(value: 'GBP', child: Text('GBP (£) - British Pound')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR (€) - Euro')),
                            DropdownMenuItem(value: 'SAR', child: Text('SAR (﷼) - Saudi Riyal')),
                            DropdownMenuItem(value: 'AED', child: Text('AED (د.إ) - UAE Dirham')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedCurrency = val);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final newName = nameCtrl.text.trim();
                          final newEmail = emailCtrl.text.trim();
                          final newPhone = phoneCtrl.text.trim();
                          final newAvatar = avatarCtrl.text.trim();
                          final newBio = bioCtrl.text.trim();

                          setState(() {
                            _userName = newName;
                            _userEmail = newEmail;
                            _userPhone = newPhone;
                            _userAvatarUrl = newAvatar;
                            _userBio = newBio;
                            _selectedCurrency = selectedCurrency;
                          });

                          await ref.read(authControllerProvider.notifier).updateUserProfile(
                                name: newName,
                                email: newEmail,
                                phone: newPhone,
                                avatarUrl: newAvatar,
                                preferredCurrency: selectedCurrency,
                                bio: newBio,
                              );

                          if (modalCtx.mounted) {
                            Navigator.pop(modalCtx);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile information updated & synced!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        },
                        child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            height: MediaQuery.of(context).size.height * 0.78,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Delivery Addresses', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          '${_addresses.length} saved location${_addresses.length == 1 ? '' : 's'}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () {
                        _showAddressFormModal(onSaved: () {
                          setModalState(() {});
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_isLoadingAddresses && _addresses.isEmpty)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_addresses.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_off_rounded, color: AppColors.primary, size: 36),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No Delivery Addresses Saved',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add your residence or office address for fast 1-tap checkout.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                            label: const Text('Add Your First Address'),
                            onPressed: () {
                              _showAddressFormModal(onSaved: () {
                                setModalState(() {});
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await _loadAddresses();
                        setModalState(() {});
                      },
                      color: AppColors.primary,
                      child: ListView.separated(
                        itemCount: _addresses.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _addresses[index];
                          return _buildAddressCard(
                            address: item,
                            onSetDefault: () async {
                              await _setDefaultAddress(item);
                              setModalState(() {});
                            },
                            onEdit: () {
                              _showAddressFormModal(
                                existingAddress: item,
                                onSaved: () {
                                  setModalState(() {});
                                },
                              );
                            },
                            onDelete: () async {
                              await _deleteAddress(item);
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required UserAddress address,
    required VoidCallback onSetDefault,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final isDefault = address.isDefault;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDefault ? AppColors.primaryContainer.withValues(alpha: 0.35) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? AppColors.primary : AppColors.border,
          width: isDefault ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Default Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDefault ? AppColors.primary : AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      address.title.toLowerCase().contains('office') || address.title.toLowerCase().contains('work')
                          ? Icons.business_rounded
                          : Icons.home_rounded,
                      color: isDefault ? Colors.white : AppColors.primary,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    address.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                  ),
                ],
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('DEFAULT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Recipient & Phone
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                address.recipientName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                address.phoneNumber,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Full Street Address
          Text(
            '${address.streetAddress}, ${address.city}, ${address.state}${address.postalCode != null && address.postalCode!.isNotEmpty ? ' (${address.postalCode})' : ''}, ${address.country ?? 'Nigeria'}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
          ),

          if (address.additionalInstructions != null && address.additionalInstructions!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address.additionalInstructions!,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.border, height: 1),
          ),

          // Action Buttons
          Row(
            children: [
              if (!isDefault)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: const Text('Set as Default', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: onSetDefault,
                )
              else
                const Row(
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: AppColors.accentGreen),
                    SizedBox(width: 4),
                    Text('Active Delivery Target', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGreen)),
                  ],
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                tooltip: 'Edit Address',
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                tooltip: 'Delete Address',
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddressFormModal({UserAddress? existingAddress, VoidCallback? onSaved}) {
    final titleCtrl = TextEditingController(text: existingAddress?.title ?? 'Home');
    final nameCtrl = TextEditingController(
      text: existingAddress?.recipientName ?? (_userName.isNotEmpty ? _userName : ref.read(authControllerProvider).user?.name ?? ''),
    );
    final phoneCtrl = TextEditingController(
      text: existingAddress?.phoneNumber ?? (_userPhone.isNotEmpty ? _userPhone : ref.read(authControllerProvider).user?.phone ?? ''),
    );
    final streetCtrl = TextEditingController(text: existingAddress?.streetAddress ?? '');
    final cityCtrl = TextEditingController(text: existingAddress?.city ?? '');
    final stateCtrl = TextEditingController(text: existingAddress?.state ?? 'Lagos');
    final postalCtrl = TextEditingController(text: existingAddress?.postalCode ?? '');
    final notesCtrl = TextEditingController(text: existingAddress?.additionalInstructions ?? '');
    bool isDefault = existingAddress?.isDefault ?? (_addresses.isEmpty);

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (formCtx) => StatefulBuilder(
        builder: (ctx, setFormState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(formCtx).viewInsets.bottom),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(22),
              child: Form(
                key: formKey,
                child: Column(
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
                        Text(
                          existingAddress != null ? 'Edit Delivery Address' : 'New Delivery Address',
                          style: AppTextStyles.productTitle.copyWith(fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(formCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Address Label', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: ['Home', 'Office', 'Family House', 'Villa', 'Apartment'].map((label) {
                                final isSelected = titleCtrl.text.trim() == label;
                                return ChoiceChip(
                                  label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryContainer,
                                  onSelected: (val) {
                                    if (val) {
                                      setFormState(() => titleCtrl.text = label);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: titleCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Custom Title',
                                prefixIcon: Icon(Icons.label_outline_rounded, color: AppColors.primary),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Recipient Full Name',
                                prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter recipient name' : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: phoneCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Contact Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                                border: OutlineInputBorder(),
                                hintText: '+234 803 123 4567',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter contact phone' : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: streetCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Street Address (House No, Street, Estate)',
                                prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter street address' : null,
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: cityCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'City / Area',
                                      prefixIcon: Icon(Icons.location_city_rounded, color: AppColors.primary),
                                      border: OutlineInputBorder(),
                                      hintText: 'e.g. Lekki, Ikeja, Wuse',
                                    ),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: postalCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Postal Code (Optional)',
                                      prefixIcon: Icon(Icons.markunread_mailbox_outlined, color: AppColors.primary),
                                      border: OutlineInputBorder(),
                                      hintText: '105102',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            const Text('State', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: ['Lagos', 'Abuja FCT', 'Kano', 'Rivers', 'Oyo', 'Kaduna', 'Ogun', 'Enugu'].map((st) {
                                final isSelected = stateCtrl.text.trim() == st;
                                return ChoiceChip(
                                  label: Text(st, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryContainer,
                                  onSelected: (val) {
                                    if (val) {
                                      setFormState(() => stateCtrl.text = st);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),

                            TextFormField(
                              controller: stateCtrl,
                              decoration: const InputDecoration(
                                labelText: 'State Name',
                                prefixIcon: Icon(Icons.map_outlined, color: AppColors.primary),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please specify state' : null,
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: notesCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Delivery Instructions (Optional)',
                                prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.primary),
                                border: OutlineInputBorder(),
                                hintText: 'e.g. Leave with gate security, call when outside',
                              ),
                            ),
                            const SizedBox(height: 14),

                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Set as Default Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: const Text('Used automatically during 1-tap checkout', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              value: isDefault,
                              activeTrackColor: AppColors.primary,
                              onChanged: (val) => setFormState(() => isDefault = val),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final userEmail = ref.read(authControllerProvider).user?.email ?? _userEmail;
                          final newAddress = UserAddress(
                            id: existingAddress?.id,
                            userEmail: userEmail,
                            title: titleCtrl.text.trim(),
                            recipientName: nameCtrl.text.trim(),
                            phoneNumber: phoneCtrl.text.trim(),
                            streetAddress: streetCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            state: stateCtrl.text.trim(),
                            postalCode: postalCtrl.text.trim(),
                            country: 'Nigeria',
                            isDefault: isDefault,
                            additionalInstructions: notesCtrl.text.trim(),
                          );

                          Navigator.pop(formCtx);
                          await _saveAddress(newAddress);
                          onSaved?.call();
                        },
                        child: Text(
                          existingAddress != null ? 'Update Address' : 'Save New Address',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAddress(UserAddress address) async {
    try {
      final saved = await client.user.saveAddress(address: address);
      await _loadAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delivery address "${saved.title}" saved successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving address: $e');
      final idx = _addresses.indexWhere((a) => a.id == address.id && address.id != null);
      if (idx >= 0) {
        _addresses[idx] = address;
      } else {
        _addresses.insert(0, address);
      }
      if (address.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          if (_addresses[i] != address) {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
        }
      }
      await _cacheAddresses(_addresses);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address saved locally (offline mode).'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  Future<void> _setDefaultAddress(UserAddress address) async {
    final userEmail = ref.read(authControllerProvider).user?.email ?? _userEmail;
    if (address.id != null && userEmail.isNotEmpty) {
      try {
        await client.user.setDefaultAddress(id: address.id!, email: userEmail);
      } catch (e) {
        debugPrint('Error setting default address on server: $e');
      }
    }

    setState(() {
      _addresses = _addresses.map((a) {
        return a.copyWith(isDefault: a.id == address.id || (address.id == null && a.title == address.title));
      }).toList();
    });
    await _cacheAddresses(_addresses);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${address.title}" is now your default delivery address.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _deleteAddress(UserAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Delivery Address?'),
        content: Text('Are you sure you want to remove "${address.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dlgCtx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final userEmail = ref.read(authControllerProvider).user?.email ?? _userEmail;
      if (address.id != null && userEmail.isNotEmpty) {
        try {
          await client.user.deleteAddress(id: address.id!, email: userEmail);
        } catch (e) {
          debugPrint('Error deleting address on server: $e');
        }
      }

      setState(() {
        _addresses.removeWhere((a) => (address.id != null && a.id == address.id) || a.title == address.title);
        if (_addresses.isNotEmpty && !_addresses.any((a) => a.isDefault)) {
          _addresses[0] = _addresses[0].copyWith(isDefault: true);
        }
      });
      await _cacheAddresses(_addresses);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery address removed.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _showPaymentModal() {
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Saved Payment Methods', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 14),
            // Selar Gateway Configuration Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Selar Halal Gateway',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF16A34A), fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: SelarPaymentService.getStoreUrl(),
                    builder: (context, snapshot) {
                      final url = snapshot.data ?? SelarPaymentService.defaultStoreUrl;
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Store Link: $url',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _showEditSelarUrlDialog();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mastercard Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Icon(Icons.credit_card, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 18),
                  Text('•••• •••• •••• 4018',
                      style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.w600)),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AMINA AL-MANSOOR', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('EXP 09/28', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text('Add New Debit / Credit Card', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Secure Payment gateway form launched')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSelarUrlDialog() async {
    final currentUrl = await SelarPaymentService.getStoreUrl();
    final currentKey = await SelarPaymentService.getApiKey();
    final urlController = TextEditingController(text: currentUrl);
    final keyController = TextEditingController(text: currentKey);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Selar Gateway & API Key', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Checkout Store URL:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Used for mobile webview and web customer payments.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText: 'https://selar.com/h3wa923367',
                  prefixIcon: const Icon(Icons.link_rounded, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Third Party Integration API Key:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Used for secure webhook callbacks and Serverpod backend verification.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: keyController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'sat_...',
                  prefixIcon: const Icon(Icons.vpn_key_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newUrl = urlController.text.trim();
              final newKey = keyController.text.trim();
              if (newUrl.isNotEmpty) {
                await SelarPaymentService.setStoreUrl(newUrl);
              }
              if (newKey.isNotEmpty) {
                await SelarPaymentService.setApiKey(newKey);
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selar credentials updated: $newUrl')),
                );
                setState(() {});
              }
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  void _showSizeCalculatorModal() {
    int heightFeet = 5;
    int heightInches = 6;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          int abayaSize = 52 + ((heightFeet * 12 + heightInches - 60) ~/ 2) * 2;
          if (abayaSize < 50) abayaSize = 50;
          if (abayaSize > 62) abayaSize = 62;

          return Container(
            padding: const EdgeInsets.all(20),
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
                Text('Abaya & Thobe Modesty Size Profile', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 6),
                const Text(
                  'Select your height to calculate your ideal modest floor-grazing length.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: heightFeet,
                      items: [4, 5, 6].map((ft) => DropdownMenuItem(value: ft, child: Text('$ft ft'))).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => heightFeet = val);
                      },
                    ),
                    const SizedBox(width: 14),
                    DropdownButton<int>(
                      value: heightInches,
                      items: List.generate(12, (i) => DropdownMenuItem(value: i, child: Text('$i in'))),
                      onChanged: (val) {
                        if (val != null) setModalState(() => heightInches = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.checkroom, color: AppColors.primary, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommended Abaya Length: Size $abayaSize',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'For men\'s thobe: Size ${abayaSize}L • Grazes top of shoes perfectly.',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      final isGuest = ref.read(authControllerProvider).isGuest;
                      if (isGuest) {
                        _showGuestPrompt(
                          title: 'Save Size Profile',
                          message: 'Sign in or create an account to permanently save your custom size profile to your modesty account.',
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved: Size $abayaSize set as default modesty fit!')),
                        );
                      }
                    },
                    child: const Text('Save to My Profile'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showWishlistModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final liveFavorites = ref.watch(homeControllerProvider).favoriteProducts;
          final homeController = ref.read(homeControllerProvider.notifier);

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.72,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
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
                    Text(
                      'My Modesty Wishlist (${liveFavorites.length})',
                      style: AppTextStyles.productTitle.copyWith(fontSize: 18),
                    ),
                    if (liveFavorites.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: AppColors.primary),
                        label: const Text(
                          'Add All to Bag',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        onPressed: () {
                          for (final p in liveFavorites) {
                            ref.read(cartControllerProvider.notifier).addItem(p);
                          }
                          Navigator.pop(modalCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added all ${liveFavorites.length} wishlist items to your bag!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (liveFavorites.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceMuted,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_border_rounded,
                              size: 42,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your Wishlist is Empty',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Tap the heart icon on any abaya, hijab, or couture item to save your modesty wishlist.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.explore_outlined, size: 18),
                            label: const Text('Discover Collections'),
                            onPressed: () {
                              Navigator.pop(modalCtx);
                              if (widget.isStandalonePage) {
                                context.go(AppRoutes.home);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: liveFavorites.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (listCtx, index) {
                        final product = liveFavorites[index];
                        return _buildLiveWishlistItem(product, homeController);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveWishlistItem(ProductModel product, HomeController homeController) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ProductImage(
            imageUrl: product.imageUrl,
            width: 52,
            height: 52,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(product.price),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: 'Remove',
            onPressed: () {
              homeController.toggleFavorite(product);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed ${product.name} from wishlist.')),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              ref.read(cartControllerProvider.notifier).addItem(product);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Moved ${product.name} to bag!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Move to Bag', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPointsModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.gold, size: 28),
            const SizedBox(width: 8),
            Text('3,450 Al-Nur Points', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earn 10 points for every ₦1,000 spent on authentic Islamic modest wear.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            SizedBox(height: 14),
            Text('Available Reward Vouchers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(height: 8),
            Text('• ₦5,000 Off Any Dubai Abaya (Requires 3,000 pts)'),
            SizedBox(height: 4),
            Text('• Free Medina Silk Hijab (Requires 2,500 pts)'),
            SizedBox(height: 4),
            Text('• Free VIP Fragrant Oud Packaging (1,000 pts)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('₦5,000 Voucher redeemed and applied to your checkout!')),
              );
            },
            child: const Text('Redeem ₦5,000 Off'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker() {
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
            Text('Select Preferred Currency', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            ...['NGN (₦) - Nigerian Naira', 'USD (\$) - US Dollar', 'AED (د.إ) - UAE Dirham', 'GBP (£) - British Pound']
                .map((cur) => ListTile(
                      title: Text(cur),
                      trailing: _selectedCurrency.contains(cur.substring(0, 3))
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() => _selectedCurrency = cur);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Currency updated to $cur')),
                        );
                      },
                    )),
          ],
        ),
      ),
    );
  }

  void _showEthicalPledgeModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Our Modest & Ethical Pledge'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Al-Nur Store is committed to 100% Shariah-compliant modest dressing, ethical fair-trade artisan wages in Dubai, Morocco, and Medina, and sustainable packaging.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 12),
              Text('• Certified Non-Sheer, Opaque Weaves\n• Generous Modest Cuts & Floor Drape\n• Fair-trade Hand Embroidery Craftsmen\n• Eco-friendly biodegradeable garment covers',
                  style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood & Barakah'),
          ),
        ],
      ),
    );
  }

  void _showConciergeModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Al-Nur Modesty Concierge'),
        content: const Text(
          'Chat directly with our luxury Islamic fashion advisors for custom size tailoring or wedding Abaya recommendations.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            icon: const Icon(Icons.chat, size: 16),
            label: const Text('Start WhatsApp Chat'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connecting to Al-Nur WhatsApp Concierge (+971 50 123 4567)...')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPreferencesModal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences and app settings loaded.')),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out of Al-Nur?'),
        content: const Text('Are you sure you want to log out of your Al-Nur account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(authControllerProvider.notifier).logout();
              appRouter.go(AppRoutes.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showResetOnboardingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Reset First-Time State?'),
          ],
        ),
        content: const Text(
          'This will clear your completed onboarding status and saved credentials so you can experience the first-time user onboarding from the splash screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await OnboardingPreferences.resetForFirstTimeUser();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('First-time user experience reset. Launching Onboarding...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                context.go(AppRoutes.splash);
              }
            },
            child: const Text('Reset & Launch'),
          ),
        ],
      ),
    );
  }
}
