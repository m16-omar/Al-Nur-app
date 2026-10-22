import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final Widget? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (type) {
      case AppButtonType.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        break;
      case AppButtonType.secondary:
        bgColor = AppColors.primaryContainer;
        fgColor = AppColors.primary;
        break;
      case AppButtonType.outline:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case AppButtonType.text:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        break;
    }

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTextStyles.heroButton.copyWith(color: fgColor),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: type == AppButtonType.primary ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: content,
      ),
    );
  }
}
