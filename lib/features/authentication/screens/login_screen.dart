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

/// Next-Level, High-Impact Animated Login Screen for Quick Money.
/// Features signature dark luxury mesh background, animated ambient glowing orbs,
/// frosted glassmorphic card, rigorous 10-digit phone validation, and CustomSnackBar alerts.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // 1. Mobile Number Required check via CustomSnackBar
    if (mobile.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message:
            'Mobile number is required. Please enter your 10-digit number.',
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

    // 3. Email Address Required check via CustomSnackBar
    if (email.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message:
            'Email address is required. Please enter your registered email.',
        icon: LucideIcons.mail,
      );
      return;
    }

    // 4. Email Format validation via CustomSnackBar
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      CustomSnackBar.showTopWarning(
        context: context,
        message:
            'Please enter a valid email address (e.g. investor@gmail.com).',
        icon: LucideIcons.alertCircle,
      );
      return;
    }

    // 5. Password Required check via CustomSnackBar
    if (password.isEmpty) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Password is required. Please enter your account password.',
        icon: LucideIcons.lock,
      );
      return;
    }

    // 6. Password minimum 6 characters check via CustomSnackBar
    if (password.length < 6) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Password is too short. Minimum 6 characters required.',
        icon: LucideIcons.shieldAlert,
      );
      return;
    }

    CustomLoader.show(context, message: 'Authenticating with 256-Bit AES...');

    try {
      final success = await ref
          .read(authProvider.notifier)
      .login(mobile: cleanDigits, email: email, password: password);

      if (!mounted) return;
      CustomLoader.hide(context);

      if (success) {
        CustomSnackBar.showTopSuccess(
          context: context,
          message: 'Welcome back to Quick Money! Login successful.',
          icon: LucideIcons.shieldCheck,
        );
        context.go('/home');
      } else {
        final err =
            ref.read(authProvider).error ??
            'Invalid credentials. Please verify your mobile, email and password.';
        CustomSnackBar.showTopError(context: context, message: err);
      }
    } catch (e) {
      if (!mounted) return;
      CustomLoader.hide(context);
      CustomSnackBar.showTopError(
        context: context,
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Levitating 3D Emblem & Gradient Header ──
              const AuthHeader(
                title: 'Welcome Back',
                subtitle: 'Sign in to access your daily investments, RP orders & instant payouts',
                iconSize: 84,
              ),

              const SizedBox(height: 28),

              // ── Luxury Frosted Glass Card Container ──
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
                        // Mobile Number Field with 10-digit limit and +91 badge
                        AuthTextField(
                              controller: _mobileController,
                              label: 'Registered Mobile Number',
                              hint: 'Enter 10-digit number',
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
                            .fade(delay: 200.ms, duration: 400.ms)
                            .slideX(
                              begin: -0.1,
                              end: 0,
                              delay: 200.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 18),

                        // Registered Email Address Field
                        AuthTextField(
                              controller: _emailController,
                              label: 'Registered Email Address',
                              hint: 'Enter your registered email',
                              prefixIcon: LucideIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                              maxLength: 60,
                            )
                            .animate()
                            .fade(delay: 280.ms, duration: 400.ms)
                            .slideX(
                              begin: 0.1,
                              end: 0,
                              delay: 280.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 18),

                        // Password Field
                        AuthTextField(
                              controller: _passwordController,
                              label: 'Account Password',
                              hint: 'Enter your password (min 6 chars)',
                              prefixIcon: LucideIcons.lock,
                              isPassword: true,
                              maxLength: 20,
                            )
                            .animate()
                            .fade(delay: 360.ms, duration: 400.ms)
                            .slideX(
                              begin: -0.1,
                              end: 0,
                              delay: 360.ms,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 12),

                        // Forgot Password Link with Cyan Accent
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => context.push('/forgot-password'),
                            icon: const Icon(
                              LucideIcons.keyRound,
                              size: 13,
                              color: Color(0xFF38BDF8),
                            ),
                            label: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ).animate().fade(delay: 450.ms, duration: 350.ms),

                        const SizedBox(height: 20),

                        // High-Impact CTA Button
                        AuthButton(
                              text: 'Sign In Securely',
                              icon: LucideIcons.arrowRight,
                              isLoading: authState.isLoading,
                              onPressed: _handleLogin,
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
                  .fade(delay: 150.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    delay: 150.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 22),

              // ── Feature Micro-Highlight Banner ──
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.sparkles,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '₹100 Daily Profit Auto-Return to PhonePe',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFDE68A),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 650.ms, duration: 400.ms),

              const SizedBox(height: 18),

              // ── Create Account Switch Link ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text(
                      'Create Account',
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
              ).animate().fade(delay: 750.ms, duration: 400.ms),

              const SizedBox(height: 14),

              // ── Bottom Bank-Grade Security Pill ──
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.shieldCheck,
                      size: 12,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '256-Bit Bank-Grade AES Encryption Protected',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 850.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
