import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Brand Header
  static TextStyle brandTitle = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  static TextStyle brandSubtitle = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  // Section Headers
  static TextStyle sectionTitle = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle sectionAction = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Hero Banner Typography
  static TextStyle heroBadge = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.goldLight,
    letterSpacing: 1.5,
  );

  static TextStyle heroTitle = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.25,
  );

  static TextStyle heroSubtitle = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white.withValues(alpha: 0.85),
  );

  static TextStyle heroButton = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // AI Assistant Typography
  static TextStyle aiCardBadge = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.accentMint,
    letterSpacing: 1.2,
  );

  static TextStyle aiCardTitle = GoogleFonts.plusJakartaSans(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle aiCardSubtitle = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Colors.white.withValues(alpha: 0.8),
    height: 1.3,
  );

  static TextStyle aiCardButton = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Category & Product Typography
  static TextStyle categoryLabel = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle productTitle = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle productPrice = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle productRating = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // Search input
  static TextStyle searchHint = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
