import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final int cartCount;
  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onAddressesTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onSignOutTap;
  final String? userName;
  final String? userEmail;
  final String? userAvatarUrl;
  final bool isGuest;

  const HomeHeader({
    super.key,
    this.cartCount = 3,
    this.hasUnreadNotifications = true,
    this.onNotificationTap,
    this.onCartTap,
    this.onProfileTap,
    this.onAddressesTap,
    this.onOrdersTap,
    this.onSignOutTap,
    this.userName,
    this.userEmail,
    this.userAvatarUrl,
    this.isGuest = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo & Branding
          Expanded(
            child: Row(
              children: [
                _buildMosqueLogo(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: 'Al-Nur ',
                          style: AppTextStyles.brandTitle,
                          children: [
                            TextSpan(
                              text: 'STORE',
                              style: AppTextStyles.brandTitle.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Modest Fashion • Quality • You',
                        style: AppTextStyles.brandSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Notification Bell
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
                if (hasUnreadNotifications)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.notificationRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Cart Button with Counter Badge
          GestureDetector(
            onTap: onCartTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.textPrimary,
                    size: 21,
                  ),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // User Profile Avatar Button
          _buildUserAvatarButton(context),
        ],
      ),
    );
  }

  Widget _buildUserAvatarButton(BuildContext context) {
    final displayName = (userName != null && userName!.trim().isNotEmpty)
        ? userName!.trim()
        : 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return GestureDetector(
      onTap: () => _showUserAccountMenu(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isGuest ? AppColors.border : AppColors.gold.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isGuest
              ? const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.textPrimary,
                  size: 21,
                )
              : (userAvatarUrl != null && userAvatarUrl!.isNotEmpty)
                  ? ClipOval(
                      child: Image.network(
                        userAvatarUrl!,
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(initial),
                      ),
                    )
                  : _buildInitialsAvatar(initial),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String initial) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showUserAccountMenu(BuildContext context) {
    final displayName = (userName != null && userName!.trim().isNotEmpty)
        ? userName!.trim()
        : (isGuest ? 'Guest Shopper' : 'Al-Nur Member');
    final displayEmail = (userEmail != null && userEmail!.trim().isNotEmpty)
        ? userEmail!.trim()
        : (isGuest ? 'Sign in to access addresses & sync orders' : 'member@alnur.store');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalCtx) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Account Header matching user screenshot
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isGuest ? AppColors.surfaceMuted : AppColors.primary,
                    child: Text(
                      isGuest ? 'G' : (displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U'),
                      style: TextStyle(
                        color: isGuest ? AppColors.textPrimary : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayEmail,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: AppColors.border, height: 1),
              ),

              // Action: My Profile & Account
              _buildMenuAction(
                icon: Icons.person_outline_rounded,
                title: 'My Profile & Account Info',
                subtitle: 'Manage name, phone, avatar & currency',
                onTap: () {
                  Navigator.pop(modalCtx);
                  onProfileTap?.call();
                },
              ),

              const SizedBox(height: 6),

              // Action: Saved Delivery Addresses
              _buildMenuAction(
                icon: Icons.location_on_outlined,
                title: 'Saved Delivery Addresses',
                subtitle: 'Manage shipping locations & default address',
                onTap: () {
                  Navigator.pop(modalCtx);
                  if (onAddressesTap != null) {
                    onAddressesTap!();
                  } else {
                    onProfileTap?.call();
                  }
                },
              ),

              const SizedBox(height: 6),

              // Action: My Orders
              _buildMenuAction(
                icon: Icons.inventory_2_outlined,
                title: 'My Orders & Tracking',
                subtitle: 'Review recent modest fashion orders',
                onTap: () {
                  Navigator.pop(modalCtx);
                  onOrdersTap?.call();
                },
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border, height: 1),
              ),

              // Sign Out or Sign In
              if (isGuest)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('Sign In or Register', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(modalCtx);
                      onProfileTap?.call();
                    },
                  ),
                )
              else
                InkWell(
                  onTap: () {
                    Navigator.pop(modalCtx);
                    onSignOutTap?.call();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildMosqueLogo() {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: MosqueLogoPainter(),
      ),
    );
  }
}

class MosqueLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Draw Islamic dome arch
    final path = Path();
    path.moveTo(w * 0.15, h * 0.9);
    path.lineTo(w * 0.15, h * 0.55);
    path.cubicTo(w * 0.15, h * 0.25, w * 0.45, h * 0.12, w * 0.5, h * 0.05);
    path.cubicTo(w * 0.55, h * 0.12, w * 0.85, h * 0.25, w * 0.85, h * 0.55);
    path.lineTo(w * 0.85, h * 0.9);
    path.lineTo(w * 0.65, h * 0.9);
    path.lineTo(w * 0.65, h * 0.65);
    path.cubicTo(w * 0.65, h * 0.5, w * 0.35, h * 0.5, w * 0.35, h * 0.65);
    path.lineTo(w * 0.35, h * 0.9);
    path.close();

    canvas.drawPath(path, paint);

    // Crescent moon at apex
    final moonPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.5, h * 0.06), 2.2, moonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
