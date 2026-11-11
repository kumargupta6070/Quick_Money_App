import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/shared_design_widgets.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';

/// Next-Level, High-Impact Animated OTP Verification Screen for Quick Money.
class OtpScreen extends ConsumerStatefulWidget {
  final String? mobile;
  final String? email;
  final String? password;
  final String? invite;

  const OtpScreen({
    super.key,
    this.mobile,
    this.email,
    this.password,
    this.invite,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _focusedIndex = 0;
  bool _isLoading = false;

  int _resendCountdown = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    for (int i = 0; i < _focusNodes.length; i++) {
      final index = i;
      _focusNodes[index].addListener(() {
        if (_focusNodes[index].hasFocus) {
          setState(() => _focusedIndex = index);
        }
      });
    }
  }

  void _startCountdown() {
    _resendCountdown = 59;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    final code = _otpCode;
    if (code.length < 6) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Please enter the complete 6-digit verification code.',
        icon: LucideIcons.key,
      );
      return;
    }

    setState(() => _isLoading = true);
    CustomLoader.show(context, message: 'Verifying 256-Bit Security OTP...');

    bool success = false;
    if (widget.email != null && widget.password != null) {
      success = await ref
          .read(authProvider.notifier)
          .register(
            mobile: widget.mobile ?? '',
            email: widget.email!,
            password: widget.password!,
            inviteCode: widget.invite ?? '',
            otp: code,
          );
    } else {
      success = await ref
          .read(authProvider.notifier)
          .verifyOtp(code, email: widget.email);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    CustomLoader.hide(context);

    if (success) {
      CustomSnackBar.showTopSuccess(
        context: context,
        message: 'Account verified! ₹51.07 welcome bonus credited.',
        icon: LucideIcons.shieldCheck,
      );
      context.go('/home');
    } else {
      final error =
          ref.read(authProvider).error ??
          'Invalid or expired OTP code. Please enter the correct code.';
      CustomSnackBar.showTopError(context: context, message: error);
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;

    if (widget.email != null) {
      CustomLoader.show(
        context,
        message: 'Dispatching new OTP to your email...',
      );
      await ref
          .read(authProvider.notifier)
          .sendRegisterOtp(email: widget.email!, mobile: widget.mobile ?? '');
      if (!mounted) return;
      CustomLoader.hide(context);
    }

    _startCountdown();
    CustomSnackBar.showTopSuccess(
      context: context,
      message:
          'New security code sent to ${widget.email ?? widget.mobile ?? "your account"}!',
      icon: LucideIcons.mailCheck,
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.mobile ?? '9835913180';

    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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

              const SizedBox(height: 14),

              // Header
              AuthHeader(
                title: 'Security Verification',
                subtitle: widget.email != null
                    ? 'Enter the 6-digit code sent to ${widget.email}'
                    : 'Enter the 6-digit code sent to +91 $phone',
                iconSize: 76,
              ),

              const SizedBox(height: 32),

              // Card with 6-box OTP input
              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 26,
                    ),
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
                      children: [
                        // 6 Animated OTP Input Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            final isFocused =
                                _focusedIndex == index &&
                                _focusNodes[index].hasFocus;
                            final isFilled =
                                _controllers[index].text.isNotEmpty;

                            return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 44,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B132B),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isFocused
                                          ? const Color(0xFF00E5FF)
                                          : (isFilled
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF1E293B)),
                                      width: isFocused
                                          ? 2.0
                                          : (isFilled ? 1.5 : 1.0),
                                    ),
                                    boxShadow: isFocused
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF00E5FF)
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 14,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      cursorColor: const Color(0xFF00E5FF),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      decoration: const InputDecoration(
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        counterText: '',
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty && index < 5) {
                                          _focusNodes[index + 1].requestFocus();
                                        } else if (value.isEmpty && index > 0) {
                                          _focusNodes[index - 1].requestFocus();
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                )
                                .animate()
                                .fade(
                                  delay: (100 + index * 50).ms,
                                  duration: 300.ms,
                                )
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  delay: (100 + index * 50).ms,
                                  duration: 300.ms,
                                );
                          }),
                        ),

                        const SizedBox(height: 24),

                        // Resend Timer Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the OTP? ",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            GestureDetector(
                              onTap: _resendCountdown == 0
                                  ? _handleResend
                                  : null,
                              child: Text(
                                _resendCountdown > 0
                                    ? 'Resend in ${_resendCountdown}s'
                                    : 'Resend Code',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: _resendCountdown > 0
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF38BDF8),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fade(delay: 450.ms, duration: 350.ms),

                        const SizedBox(height: 24),

                        // Verify Button
                        AuthButton(
                              text: 'Verify & Proceed',
                              icon: LucideIcons.shieldCheck,
                              isLoading: _isLoading,
                              onPressed: _handleVerify,
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

              const SizedBox(height: 24),

              // Security Assurance Footer
              const Center(
                child: GlassCapsuleBadge(
                  label: '🔒 256-BIT ENCRYPTED VERIFICATION',
                  dotColor: Color(0xFF00E5FF),
                  borderColor: Color(0xFF2563EB),
                  fontSize: 10.5,
                ),
              ).animate().fade(delay: 650.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
