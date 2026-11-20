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

/// Next-Level, High-Impact Animated Reset/Forgot Password Screen for Quick Money.
/// Features signature dark luxury mesh background, glowing ambient orbs,
/// frosted glassmorphic card, email/phone validation, and CustomSnackBar alerts.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _inputController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    final input = _inputController.text.trim();

    // 1. Required check via CustomSnackBar
    if (input.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message:
            'Please enter your registered Email address to reset password.',
        icon: LucideIcons.mail,
      );
      return;
    }

    final isEmail = input.contains('@');
    if (!isEmail) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Please enter a valid registered Email address (e.g. investor@gmail.com).',
        icon: LucideIcons.alertCircle,
      );
      return;
    }

    setState(() => _isLoading = true);
    CustomLoader.show(
      context,
      message: 'Dispatching Password Reset OTP to your email...',
    );

    final success = await ref
        .read(authProvider.notifier)
        .sendPasswordResetOtp(input);

    if (!mounted) return;
    setState(() => _isLoading = false);
    CustomLoader.hide(context);

    if (success) {
      CustomSnackBar.showTopSuccess(
        context: context,
        message: 'Password reset security OTP sent to $input successfully.',
        icon: LucideIcons.mailCheck,
      );

      context.push('/otp', extra: {'email': input, 'type': 'forgot_password'});
    } else {
      final err =
          ref.read(authProvider).error ??
          'Could not send reset code. Please verify your email.';
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
                title: 'Reset Password',
                subtitle: 'Enter your registered email to receive an instant verification code',
                iconSize: 76,
              ),

              const SizedBox(height: 32),

              // Card with Input
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
                        // Email Field
                        AuthTextField(
                              controller: _inputController,
                              label: 'Registered Email Address',
                              hint: 'e.g. investor@gmail.com',
                              prefixIcon: LucideIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                              maxLength: 60,
                            )
                            .animate()
                            .fade(delay: 150.ms, duration: 400.ms)
                            .slideX(
                              begin: -0.1,
                              end: 0,
                              delay: 150.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 24),

                        // Send Verification Button
                        AuthButton(
                              text: 'Send Verification OTP',
                              icon: LucideIcons.send,
                              isLoading: _isLoading,
                              onPressed: _handleSendReset,
                            )
                            .animate()
                            .fade(delay: 300.ms, duration: 400.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              delay: 300.ms,
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
                    onTap: () => context.pop(),
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
