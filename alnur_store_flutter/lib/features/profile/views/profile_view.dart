import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../onboarding/services/onboarding_preferences.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileView extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onOpenCart;

  const ProfileView({
    super.key,
    this.onNavigateToOrders,
    this.onOpenCart,
  });

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  String _userName = 'Amina Al-Mansoor';
  String _userEmail = 'amina.mansoor@example.com';
  String _userPhone = '+234 803 987 6543';
  String _selectedCurrency = 'NGN (₦)';
  bool _notificationsEnabled = true;
  bool _jumuahRemindersEnabled = true;

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
    final displayName = user != null && user.name.isNotEmpty ? user.name : _userName;
    final displayEmail = user != null && user.email.isNotEmpty ? user.email : _userEmail;
    final isGuest = authState.isGuest;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
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
            onPressed: () => _showPreferencesModal(),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primaryContainer,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening photo picker to update avatar...')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    displayEmail,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  // VIP or Guest Badge
                  GestureDetector(
                    onTap: isGuest ? () => context.go(AppRoutes.login) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isGuest ? AppColors.surfaceMuted : AppColors.goldLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isGuest ? AppColors.border : AppColors.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isGuest ? Icons.person_outline_rounded : Icons.workspace_premium_rounded,
                            color: isGuest ? AppColors.primary : AppColors.goldDark,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isGuest ? 'Guest Shopper (Tap to Sign In)' : 'Gold VIP Modesty Member',
                            style: TextStyle(
                              color: isGuest ? AppColors.primary : AppColors.goldDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                    count: '12',
                    label: 'Orders',
                    color: AppColors.primaryDark,
                    onTap: widget.onNavigateToOrders ?? () => context.push(AppRoutes.orders),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.favorite_border_rounded,
                    count: '8',
                    label: 'Favorites',
                    color: const Color(0xFFE11D48),
                    onTap: () => _showWishlistModal(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.stars_rounded,
                    count: '3,450',
                    label: 'Al-Nur Pts',
                    color: AppColors.goldDark,
                    onTap: () => _showPointsModal(),
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
                subtitle: 'Name, phone number, and modesty sizing',
                onTap: () => _showEditProfileModal(),
              ),
              _buildListTile(
                icon: Icons.location_on_outlined,
                title: 'Saved Delivery Addresses',
                subtitle: 'Lekki Phase 1, Lagos & Maitama, Abuja',
                onTap: () => _showAddressesModal(),
              ),
              _buildListTile(
                icon: Icons.payment_outlined,
                title: 'Payment & Cards',
                subtitle: 'Mastercard ending in 4018',
                onTap: () => _showPaymentModal(),
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
              _buildListTile(
                icon: Icons.restart_alt_rounded,
                title: 'Reset First-Time User Experience',
                subtitle: 'Clear saved state to test initial onboarding',
                onTap: () => _showResetOnboardingDialog(),
              ),
            ]),

            const SizedBox(height: 24),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
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

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    final phoneCtrl = TextEditingController(text: _userPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
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
              Text('Edit Personal Profile', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
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
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
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
                    setState(() {
                      _userName = nameCtrl.text;
                      _userEmail = emailCtrl.text;
                      _userPhone = phoneCtrl.text;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile information updated successfully!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
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
                Text('Delivery Addresses', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: const Text('Add New', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address form opened')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAddressCard(
              title: 'Primary Residence (Lagos)',
              address: 'Plot 14, Admiralty Way, Lekki Phase 1, Lagos State',
              phone: '+234 803 987 6543',
              isDefault: true,
            ),
            const SizedBox(height: 12),
            _buildAddressCard(
              title: 'Abuja Office (FCT)',
              address: 'No. 8, Gana Street, Maitama, Abuja FCT',
              phone: '+234 802 111 2233',
              isDefault: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String address,
    required String phone,
    required bool isDefault,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDefault ? AppColors.primaryContainer.withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDefault ? AppColors.primary : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('DEFAULT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(phone, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4D3E), Color(0xFF0F2E25)],
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved: Size $abayaSize set as default modesty fit!')),
                      );
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
            Text('My Modesty Wishlist (8 items)', style: AppTextStyles.productTitle.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildWishlistItem(
                    name: 'Dubai Gold Noir Abaya',
                    price: '₦28,500',
                    imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?auto=format&fit=crop&w=500&q=80',
                  ),
                  _buildWishlistItem(
                    name: 'Sage Emerald Medina Hijab',
                    price: '₦8,800',
                    imageUrl: 'https://images.unsplash.com/photo-1596704017254-9b121068fb31?auto=format&fit=crop&w=500&q=80',
                  ),
                  _buildWishlistItem(
                    name: 'Gold Embellished Eid Jalabia',
                    price: '₦45,000',
                    imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=500&q=80',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistItem({required String name, required String price, required String imageUrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(price, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added $name to cart!')),
              );
            },
            child: const Text('Add to Bag', style: TextStyle(fontSize: 11)),
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out of Al-Nur?'),
        content: const Text('Are you sure you want to log out of your Al-Nur account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
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
