import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';

/// Enterprise, High-Impact Set New Password Screen for Quick Money.
/// Matches ForgotPasswordScreen and RegisterScreen pixel-for-pixel with signature
/// dark mesh background, glowing ambient borders, clean validation, and proper back navigation.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSavePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 1. New Password Required
    if (newPassword.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Please enter your new account password.',
        icon: LucideIcons.lock,
      );
      return;
    }

    // 2. Minimum 6 Characters
    if (newPassword.length < 6) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Password is too short. Minimum 6 characters required.',
        icon: LucideIcons.shieldAlert,
      );
      return;
    }

    // 3. Confirm Password Required
    if (confirmPassword.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Please re-enter your password to confirm.',
        icon: LucideIcons.shieldCheck,
      );
      return;
    }

    // 4. Passwords Match Check
    if (newPassword != confirmPassword) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Passwords do not match. Please verify both fields.',
        icon: LucideIcons.alertTriangle,
      );
      return;
    }

    setState(() => _isLoading = true);
    CustomLoader.show(
      context,
      message: 'Encrypting and updating password in secure vault...',
    );

    final success = await ref.read(authProvider.notifier).resetPassword(
          email: widget.email,
          otp: widget.otp,
          newPassword: newPassword,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);
    CustomLoader.hide(context);

    if (success) {
      CustomSnackBar.showTopSuccess(
        context: context,
        message:
            'Password updated successfully! Please sign in with your new password.',
        icon: LucideIcons.shieldCheck,
      );
      context.go('/login');
    } else {
      final err = ref.read(authProvider).error ??
          'Failed to update password. Please check your network and try again.';
      CustomSnackBar.showTopError(context: context, message: err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Back Button
              Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B)
                            .withValues(alpha: 0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF334155)),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fade(duration: 300.ms)
                  .slideX(begin: -0.2, end: 0, duration: 300.ms),

              const SizedBox(height: 16),

              // Header
              const AuthHeader(
                title: 'Set New Password',
                subtitle:
                    'Create a secure 6+ character password to safeguard your account',
                iconSize: 76,
              ),

              const SizedBox(height: 32),

              // Card with Inputs
              Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF)
                              .withValues(alpha: 0.12),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // New Password Field
                        AuthTextField(
                              controller: _newPasswordController,
                              label: 'New Account Password',
                              hint: 'Minimum 6 characters',
                              prefixIcon: LucideIcons.lock,
                              isPassword: true,
                              maxLength: 30,
                            )
                            .animate()
                            .fade(delay: 150.ms, duration: 400.ms)
                            .slideX(
                              begin: -0.1,
                              end: 0,
                              delay: 150.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 18),

                        // Confirm Password Field
                        AuthTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm New Password',
                              hint: 'Re-enter your new password',
                              prefixIcon: LucideIcons.shieldCheck,
                              isPassword: true,
                              maxLength: 30,
                            )
                            .animate()
                            .fade(delay: 250.ms, duration: 400.ms)
                            .slideX(
                              begin: 0.1,
                              end: 0,
                              delay: 250.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 26),

                        // Save Password Button
                        AuthButton(
                              text: 'Save New Password',
                              icon: LucideIcons.shieldCheck,
                              isLoading: _isLoading,
                              onPressed: _handleSavePassword,
                            )
                            .animate()
                            .fade(delay: 350.ms, duration: 400.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              delay: 350.ms,
                              duration: 350.ms,
                            ),
                      ],
                    ),
                  )
                  .animate()
                  .fade(delay: 100.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    delay: 100.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 24),

              // Switch Link to Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Remember your password? ',
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF38BDF8),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                ],
              ).animate().fade(delay: 450.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
