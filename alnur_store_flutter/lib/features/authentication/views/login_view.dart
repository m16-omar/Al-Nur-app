import 'package:alnur_store_client/alnur_store_client.dart';
import '../../../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_auth_buttons.dart';

import '../../onboarding/services/onboarding_preferences.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _savedUserName;
  bool _isReturningUser = false;

  @override
  void initState() {
    super.initState();
    _loadReturningUserData();
  }

  Future<void> _loadReturningUserData() async {
    final completed = await OnboardingPreferences.hasCompletedOnboarding();
    final name = await OnboardingPreferences.getSavedUserName();
    final email = await OnboardingPreferences.getSavedUserEmail();

    if (mounted) {
      setState(() {
        _isReturningUser = completed;
        _savedUserName = name;
        if (email != null && email.isNotEmpty) {
          _emailController.text = email;
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final success = await ref.read(authControllerProvider.notifier).login(
          email: email,
          password: password,
        );

    if (success && mounted) {
      final user = ref.read(authControllerProvider).user;
      final name = user?.name ?? _savedUserName ?? 'Member';

      await OnboardingPreferences.saveUserName(name);
      await OnboardingPreferences.saveUserEmail(email);
      await OnboardingPreferences.setOnboardingCompleted(completed: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Assalamu Alaikum! Welcome back, $name.'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
        context.go(AppRoutes.home);
      }
    }
  }

  void _handleContinueAsGuest() async {
    await OnboardingPreferences.setOnboardingCompleted(completed: true);
    ref.read(authControllerProvider.notifier).continueAsGuest();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ahlan wa Sahlan! Browsing as Guest.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Auth Header with 3D Arch Emblem
              const AuthHeader(
                title: 'Welcome Back',
                subtitle: 'Sign in to access your curated modest collections',
              ),
              const SizedBox(height: 20),

              // Returning User Personalized Pill
              if (_isReturningUser || _savedUserName != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF4E6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, color: AppColors.goldDark, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _savedUserName != null
                                  ? 'Assalamu Alaikum, $_savedUserName'
                                  : 'Assalamu Alaikum! (Returning Shopper)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Welcome back to your curated modest collections',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _savedUserName = null;
                            _isReturningUser = false;
                            _emailController.clear();
                            _passwordController.clear();
                          });
                        },
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        child: const Text('Switch', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 12),

              // Error Message Banner (if any)
              if (authState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Email / Username Input
              AppTextField(
                controller: _emailController,
                labelText: 'Email Address or Phone',
                hintText: 'e.g. aisha@alnur.store',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 18),

              // Password Input
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Remember Me & Forgot Password Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: authState.rememberMe,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            ref
                                .read(authControllerProvider.notifier)
                                .toggleRememberMe(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember Me',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _showForgotPasswordModal(),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Demo Credentials Pill
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ActionChip(
                    avatar: const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primary),
                    label: const Text('Quick Fill Demo (Amina)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: AppColors.primary, width: 0.8),
                    onPressed: () {
                      _emailController.text = 'amina@alnur.store';
                      _passwordController.text = 'password123';
                    },
                  ),
                ),
              ),

              // Sign In Button
              AppButton(
                text: 'Sign In',
                isLoading: authState.isLoading,
                height: 52,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 28),

              // Social Auth Buttons
              SocialAuthButtons(
                onGooglePressed: () {
                  _emailController.text = 'google.user@alnur.store';
                  _passwordController.text = '12345678';
                  _handleLogin();
                },
                onApplePressed: () {
                  _emailController.text = 'apple.user@alnur.store';
                  _passwordController.text = '12345678';
                  _handleLogin();
                },
              ),
              const SizedBox(height: 28),

              // Don't have an account? Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.signUp),
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Continue as Guest Link
              Center(
                child: GestureDetector(
                  onTap: _handleContinueAsGuest,
                  child: Text(
                    'Continue as Guest',
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordModal() {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    int step = 1; // 1: Email, 2: Code, 3: New Password
    UuidValue? resetRequestId;
    String? finishResetToken;
    bool isSubmitting = false;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Widget stepContent;

          if (step == 1) {
            stepContent = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter your registered email address to receive an 8-character verification code.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: resetEmailController,
                  hintText: 'e.g. zainab@alnur.store',
                  labelText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.primary, size: 20),
                ),
                if (localError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    localError!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  text: 'Send Verification Code',
                  isLoading: isSubmitting,
                  onPressed: () async {
                    final email = resetEmailController.text.trim();
                    if (email.isEmpty) {
                      setModalState(() => localError = 'Please enter your email.');
                      return;
                    }

                    setModalState(() {
                      isSubmitting = true;
                      localError = null;
                    });

                    try {
                      final reqId = await client.emailIdp
                          .startPasswordReset(email: email);
                      setModalState(() {
                        resetRequestId = reqId;
                        step = 2;
                        isSubmitting = false;
                        localError = null;
                      });
                    } catch (e) {
                      setModalState(() {
                        isSubmitting = false;
                        localError =
                            'Unable to send reset code: ${e.toString().replaceAll('Exception:', '').trim()}';
                      });
                    }
                  },
                ),
              ],
            );
          } else if (step == 2) {
            stepContent = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'A verification code has been dispatched to ${resetEmailController.text.trim()}. Please enter it below:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: otpController,
                  hintText: 'Enter 8-digit OTP code',
                  labelText: 'Verification Code',
                  prefixIcon: const Icon(Icons.pin_outlined,
                      color: AppColors.primary, size: 20),
                ),
                if (localError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    localError!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final email = resetEmailController.text.trim();
                            setModalState(() => isSubmitting = true);
                            try {
                              final reqId = await client.emailIdp
                                  .startPasswordReset(email: email);
                              setModalState(() {
                                resetRequestId = reqId;
                                isSubmitting = false;
                                localError = 'New code sent to $email';
                              });
                            } catch (e) {
                              setModalState(() {
                                isSubmitting = false;
                                localError = 'Failed to resend code';
                              });
                            }
                          },
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Verify Code',
                  isLoading: isSubmitting,
                  onPressed: () async {
                    final code = otpController.text.trim();
                    if (code.isEmpty) {
                      setModalState(
                          () => localError = 'Please enter the verification code.');
                      return;
                    }
                    if (resetRequestId == null) {
                      setModalState(() {
                        step = 1;
                        localError = 'Session expired. Please request a new code.';
                      });
                      return;
                    }

                    setModalState(() {
                      isSubmitting = true;
                      localError = null;
                    });

                    try {
                      final token = await client.emailIdp
                          .verifyPasswordResetCode(
                        passwordResetRequestId: resetRequestId!,
                        verificationCode: code,
                      );
                      setModalState(() {
                        finishResetToken = token;
                        step = 3;
                        isSubmitting = false;
                        localError = null;
                      });
                    } catch (e) {
                      setModalState(() {
                        isSubmitting = false;
                        localError =
                            'Invalid or expired code. Please check and try again.';
                      });
                    }
                  },
                ),
              ],
            );
          } else {
            stepContent = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Code verified! Create a secure new password for your Al-Nur account.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: newPasswordController,
                  hintText: 'Enter new password',
                  labelText: 'New Password',
                  obscureText: obscureNew,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.primary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setModalState(() => obscureNew = !obscureNew),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm new password',
                  labelText: 'Confirm Password',
                  obscureText: obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.primary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setModalState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
                if (localError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    localError!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  text: 'Save New Password',
                  isLoading: isSubmitting,
                  onPressed: () async {
                    final newPass = newPasswordController.text.trim();
                    final confirmPass = confirmPasswordController.text.trim();

                    if (newPass.isEmpty) {
                      setModalState(
                          () => localError = 'Please enter a new password.');
                      return;
                    }
                    if (newPass.length < 8) {
                      setModalState(() => localError =
                          'Password must be at least 8 characters long.');
                      return;
                    }
                    if (newPass != confirmPass) {
                      setModalState(
                          () => localError = 'Passwords do not match.');
                      return;
                    }
                    if (finishResetToken == null) {
                      setModalState(() {
                        step = 1;
                        localError =
                            'Reset token missing. Please start over.';
                      });
                      return;
                    }

                    setModalState(() {
                      isSubmitting = true;
                      localError = null;
                    });

                    try {
                      await client.emailIdp.finishPasswordReset(
                        finishPasswordResetToken: finishResetToken!,
                        newPassword: newPass,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        _emailController.text =
                            resetEmailController.text.trim();
                        _passwordController.text = newPass;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '✨ Password updated successfully! You can now log in.'),
                            backgroundColor: Color(0xFF0B291E),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    } catch (e) {
                      setModalState(() {
                        isSubmitting = false;
                        localError =
                            'Unable to reset password: ${e.toString().replaceAll('Exception:', '').trim()}';
                      });
                    }
                  },
                ),
              ],
            );
          }

          return Container(
            padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          step == 1
                              ? 'Reset Password'
                              : step == 2
                                  ? 'Verify Code'
                                  : 'New Password',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Step $step/3',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                stepContent,
              ],
            ),
          );
        },
      ),
    );
  }
}
