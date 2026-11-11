import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Next-Level, High-Impact Animated Register Screen for Quick Money.
/// Features signature dark luxury mesh background, glowing cyan/gold/purple ambient orbs,
/// frosted glass card, strict 10-digit validation, and CustomSnackBar alert triggers.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteController = TextEditingController(
    text: 'w2XZyx',
  ); // Default from client document
  bool _agreedToTerms = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final invite = _inviteController.text.trim();

    // 1. Mobile Number Required check via CustomSnackBar
    if (mobile.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Mobile number is required to register an account.',
        icon: LucideIcons.phone,
      );
      return;
    }

    // 2. Exactly 10 digits check via CustomSnackBar
    final cleanDigits = mobile.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.length != 10) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Invalid mobile number! Exactly 10 digits required (e.g. 9835913180).',
        icon: LucideIcons.alertTriangle,
      );
      return;
    }

    // 3. Email Address Required & Format Check via CustomSnackBar
    if (email.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Email address is required to receive your security OTP.',
        icon: LucideIcons.mail,
      );
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Please enter a valid email address (e.g. investor@gmail.com).',
        icon: LucideIcons.alertCircle,
      );
      return;
    }

    // 4. Password Required check via CustomSnackBar
    if (password.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Password is required. Please create a password for your account.',
        icon: LucideIcons.lock,
      );
      return;
    }

    // 5. Password minimum 6 characters check via CustomSnackBar
    if (password.length < 6) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Password is too short. Minimum 6 characters required.',
        icon: LucideIcons.shieldAlert,
      );
      return;
    }

    // 6. Invitation Code Required check via CustomSnackBar
    if (invite.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Invitation referral code is required to join Quick Money.',
        icon: LucideIcons.gift,
      );
      return;
    }

    // 7. Terms Checkbox check via CustomSnackBar
    if (!_agreedToTerms) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Please agree to Terms of Service & Privacy Policy to register.',
        icon: LucideIcons.checkCheck,
      );
      return;
    }

    setState(() => _isLoading = true);
    CustomLoader.show(
      context,
      message: 'Generating 256-Bit Security OTP...',
    );

    final success = await ref.read(authProvider.notifier).sendRegisterOtp(
          email: email,
          mobile: cleanDigits,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);
    CustomLoader.hide(context);

    if (success) {
      CustomSnackBar.showTopSuccess(
        context: context,
        message: 'Verification code sent to $email! Please verify.',
        icon: LucideIcons.mailCheck,
      );

      context.push(
        '/otp',
        extra: {
          'mobile': cleanDigits,
          'email': email,
          'password': password,
          'invite': invite,
        },
      );
    } else {
      final error = ref.read(authProvider).error ?? 'Failed to send security code. Please try again.';
      CustomSnackBar.showTopError(
        context: context,
        message: error,
      );
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

              const SizedBox(height: 10),

              // Top Levitating Emblem & Header
              const AuthHeader(
                title: 'Join Quick Money',
                subtitle: 'Invest daily, earn RP rewards, and receive automatic PhonePe returns',
                iconSize: 76,
              ),

              const SizedBox(height: 24),

              // Luxury Glass Card Container
              Container(
                    padding: const EdgeInsets.all(22),
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
                        // Mobile Field with 10-digit formatters & +91 badge
                        AuthTextField(
                              controller: _mobileController,
                              label: 'Registered Mobile Number',
                              hint: 'Enter 10-digit mobile number',
                              prefixIcon: LucideIcons.phone,
                              isPhone: true,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            )
                            .animate()
                            .fade(delay: 150.ms, duration: 400.ms)
                            .slideX(
                              begin: -0.1,
                              end: 0,
                              delay: 150.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 16),

                        // Email Field (for Brevo Email OTP)
                        AuthTextField(
                              controller: _emailController,
                              label: 'Email Address (for Security OTP)',
                              hint: 'e.g. investor@gmail.com',
                              prefixIcon: LucideIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                              maxLength: 60,
                            )
                            .animate()
                            .fade(delay: 200.ms, duration: 400.ms)
                            .slideX(
                              begin: 0.1,
                              end: 0,
                              delay: 200.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 16),

                        // Password Field
                        AuthTextField(
                              controller: _passwordController,
                              label: 'Create Account Password',
                              hint: 'Minimum 6 characters',
                              prefixIcon: LucideIcons.lock,
                              isPassword: true,
                              maxLength: 20,
                            )
                            .animate()
                            .fade(delay: 250.ms, duration: 400.ms)
                            .slideX(
                              begin: 0.1,
                              end: 0,
                              delay: 250.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 16),

                        // Invitation Code Field
                        AuthTextField(
                              controller: _inviteController,
                              label: 'Invitation / Referral Code',
                              hint: 'Enter referral code',
                              prefixIcon: LucideIcons.gift,
                              maxLength: 12,
                            )
                            .animate()
                            .fade(delay: 350.ms, duration: 400.ms)
                            .slideX(
                              begin: -0.1,
                              end: 0,
                              delay: 350.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 16),

                        // Terms Checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (val) => setState(
                                  () => _agreedToTerms = val ?? true,
                                ),
                                activeColor: const Color(0xFF00E5FF),
                                checkColor: const Color(0xFF070B18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'I agree to Quick Money Terms of Service & Privacy Policy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fade(delay: 450.ms, duration: 350.ms),

                        const SizedBox(height: 20),

                        // CTA Button
                        AuthButton(
                              text: 'Create Account',
                              icon: LucideIcons.userPlus,
                              isLoading: _isLoading,
                              onPressed: _handleRegister,
                            )
                            .animate()
                            .fade(delay: 550.ms, duration: 400.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              delay: 550.ms,
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

              const SizedBox(height: 22),

              // Switch Link to Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
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
              ).animate().fade(delay: 650.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
