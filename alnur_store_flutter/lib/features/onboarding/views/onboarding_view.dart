import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/onboarding_item.dart';
import '../services/onboarding_preferences.dart';
import '../widgets/onboarding_card.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isReturningUser = false;
  String? _savedUserName;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final completed = await OnboardingPreferences.hasCompletedOnboarding();
    final name = await OnboardingPreferences.getSavedUserName();
    if (mounted) {
      setState(() {
        _isReturningUser = completed;
        _savedUserName = name;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < OnboardingItem.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      if (_isReturningUser) {
        context.go(AppRoutes.home);
      } else {
        _completeAndGo(AppRoutes.signUp);
      }
    }
  }

  Future<void> _completeAndGo(String route) async {
    await OnboardingPreferences.setOnboardingCompleted(completed: true);
    if (mounted) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = OnboardingItem.items;
    final isLastPage = _currentIndex == items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Al-Nur Brand Micro Logo & Status Badge
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                            size: 19,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Al-Nur',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (_isReturningUser)
                            Text(
                              _savedUserName != null
                                  ? 'Welcome back, $_savedUserName'
                                  : 'Modesty Tour',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldDark,
                              ),
                            )
                          else
                            const Text(
                              'First Time Welcome',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Action Button: Exit / Skip
                  if (_isReturningUser)
                    TextButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: Text(
                        'Exit to Shop',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () => _completeAndGo(AppRoutes.home),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text(
                        'Skip to Store',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page View with 3D Onboarding Cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingCard(
                    item: items[index],
                    index: index,
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smooth Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(items.length, (index) {
                      final isActive = _currentIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 28 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Different Actions based on Page and User Type
                  if (!isLastPage) ...[
                    // Pages 1 & 2: Next Button
                    AppButton(
                      text: 'Next',
                      width: double.infinity,
                      height: 52,
                      onPressed: _onNext,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _completeAndGo(AppRoutes.home),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _isReturningUser ? 'Back to Modest Collections' : 'Continue as Guest',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.border,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Final Page (Page 3): Tailored CTAs for First-Time vs Returning Users
                    if (_isReturningUser) ...[
                      // Returning User Final Page Options
                      AppButton(
                        text: 'Return to Modest Collections',
                        width: double.infinity,
                        height: 52,
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text(
                          'Sign In to Existing Account',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                    ] else ...[
                      // First-Time User Final Page Options
                      AppButton(
                        text: 'Create Account • Claim 15% OFF',
                        width: double.infinity,
                        height: 52,
                        onPressed: () => _completeAndGo(AppRoutes.signUp),
                        icon: const Icon(Icons.card_giftcard_rounded, size: 20),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border),
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.storefront_outlined, size: 18),
                        label: const Text(
                          'Explore Store as Guest',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        onPressed: () => _completeAndGo(AppRoutes.home),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _completeAndGo(AppRoutes.login),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already an Al-Nur Member? ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
