import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final int cartCount;
  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;

  const HomeHeader({
    super.key,
    this.cartCount = 3,
    this.hasUnreadNotifications = true,
    this.onNotificationTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo & Branding
          Row(
            children: [
              _buildMosqueLogo(),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
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
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

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

          const SizedBox(width: 12),

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
        ],
      ),
    );
  }

  Widget _buildMosqueLogo() {
    return Container(
      width: 42,
      height: 42,
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
