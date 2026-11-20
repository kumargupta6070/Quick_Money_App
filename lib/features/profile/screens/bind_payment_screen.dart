import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/wallet_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/bind_payment_action_button.dart';
import '../widgets/bind_payment_checklist_card.dart';
import '../widgets/bind_payment_guarantee_banner.dart';
import '../widgets/bind_payment_handles_bar.dart';
import '../widgets/bind_payment_hero_header.dart';
import '../widgets/bind_payment_provider_card.dart';
import '../widgets/bind_payment_text_field_card.dart';

/// Next-Level Ultra FinTech Bind Payment APP Screen
/// Features dynamic provider themes, animated cascading entrance,
/// glowing provider selection cards, instant UPI handle injection,
/// bank-grade security badges, and PhonePe ₹100 auto-settlement integration.
class BindPaymentScreen extends ConsumerStatefulWidget {
  const BindPaymentScreen({super.key});

  @override
  ConsumerState<BindPaymentScreen> createState() => _BindPaymentScreenState();
}

class _BindPaymentScreenState extends ConsumerState<BindPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedApp = 'phonepe';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final wallet = ref.read(walletProvider);
    _upiController.text = wallet.upiId;
    _nameController.text = wallet.accountHolderName ?? 'Primary PhonePe Wallet';
    _selectedApp = wallet.paymentApp;
    _upiController.addListener(() => setState(() {}));
    _nameController.addListener(() => setState(() {}));

    Future.microtask(() async {
      await ref.read(walletProvider.notifier).fetchWallet();
      if (!mounted) return;
      final liveWallet = ref.read(walletProvider);
      if (liveWallet.upiId.isNotEmpty &&
          liveWallet.upiId != _upiController.text) {
        setState(() {
          _upiController.text = liveWallet.upiId;
          _nameController.text =
              liveWallet.accountHolderName ?? 'Primary PhonePe Wallet';
          _selectedApp = liveWallet.paymentApp;
        });
      }
    });
  }

  @override
  void dispose() {
    _upiController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _pasteFromClipboard() async {
    HapticFeedback.lightImpact();
    final data = await Clipboard.getData('text/plain');
    if (!mounted) return;
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _upiController.text = data.text!.trim();
      });
      CustomSnackBar.showSuccess(
        context: context,
        message: 'Pasted UPI from clipboard!',
        icon: LucideIcons.clipboardCheck,
      );
    }
  }

  void _appendUpiHandle(String handle) {
    HapticFeedback.lightImpact();
    final current = _upiController.text.trim();
    if (current.contains('@')) {
      final prefix = current.split('@').first;
      _upiController.text = '$prefix$handle';
    } else if (current.isNotEmpty) {
      _upiController.text = '$current$handle';
    } else {
      _upiController.text = '919835913180$handle';
    }
    _upiController.selection = TextSelection.fromPosition(
      TextPosition(offset: _upiController.text.length),
    );
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      setState(() => _isLoading = true);
      CustomLoader.showOverlay(
        context,
        message:
            'Binding $_selectedProviderName UPI with AES-256 verification...',
      );

      final success = await ref
          .read(walletProvider.notifier)
          .bindWallet(
            upiId: _upiController.text.trim(),
            paymentApp: _selectedApp,
            accountHolderName: _nameController.text.trim(),
          );

      if (!mounted) return;
      CustomLoader.dismiss(context);
      setState(() => _isLoading = false);

      if (success) {
        CustomSnackBar.showSuccess(
          context: context,
          message:
              'Wallet bound successfully! $_selectedProviderName ₹100 auto-returns are now active.',
          icon: LucideIcons.shieldCheck,
        );
        context.pop();
      } else {
        CustomSnackBar.showError(
          context: context,
          message:
              'Failed to bind wallet. Please check connection and try again.',
        );
      }
    }
  }

  String get _selectedProviderName {
    switch (_selectedApp) {
      case 'gpay':
        return 'Google Pay';
      case 'paytm':
        return 'Paytm UPI';
      case 'phonepe':
      default:
        return 'PhonePe';
    }
  }

  Color get _providerPrimaryColor {
    switch (_selectedApp) {
      case 'gpay':
        return const Color(0xFF1A73E8);
      case 'paytm':
        return const Color(0xFF00BAF2);
      case 'phonepe':
      default:
        return const Color(0xFF6B21A8);
    }
  }

  Color get _providerAccentColor {
    switch (_selectedApp) {
      case 'gpay':
        return const Color(0xFF4285F4);
      case 'paytm':
        return const Color(0xFF0082C8);
      case 'phonepe':
      default:
        return const Color(0xFF9333EA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Royal FinTech Hero Curved Header ──
              BindPaymentHeroHeader(isDark: isDark)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 16),

              // ── 2. Form Container Body ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ₹100 Auto-Return Guarantee Showcase Card
                      BindPaymentGuaranteeBanner(
                        selectedProviderName: _selectedProviderName,
                        isDark: isDark,
                      )
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 400.ms)
                          .slideY(
                            begin: 0.08,
                            end: 0,
                            delay: 80.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 22),

                      // Payment App Provider Selector Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _providerPrimaryColor,
                                      _providerAccentColor,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Select Payment Provider',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _providerPrimaryColor.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Active Channel',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 140.ms, duration: 380.ms),

                      const SizedBox(height: 12),

                      // Exclusive PhonePe Provider Card
                      BindPaymentProviderCard(isDark: isDark)
                          .animate()
                          .fadeIn(delay: 180.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 180.ms),

                      const SizedBox(height: 22),

                      // Account Holder Name Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.userCheck,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF0284C7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Account Holder Name',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Verified Wallet Name',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 240.ms, duration: 380.ms),

                      const SizedBox(height: 8),

                      BindPaymentTextFieldCard(
                        controller: _nameController,
                        hintText: 'e.g. Primary PhonePe Wallet / Full Name',
                        prefixIcon: LucideIcons.user,
                        validator: (val) =>
                            val == null || val.trim().isEmpty
                                ? 'Account holder name is required'
                                : null,
                        isDark: isDark,
                        accentColor: _providerAccentColor,
                        onClear: () => _nameController.clear(),
                      )
                          .animate()
                          .fadeIn(delay: 260.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 260.ms),

                      const SizedBox(height: 20),

                      // UPI ID Field with Paste Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.wallet,
                                size: 14,
                                color: _providerAccentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_selectedProviderName UPI ID',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _pasteFromClipboard,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _providerPrimaryColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    _providerAccentColor.withValues(
                                      alpha: 0.10,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _providerAccentColor.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.clipboard,
                                    size: 13,
                                    color: _providerAccentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Paste UPI',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _providerAccentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms, duration: 380.ms),

                      const SizedBox(height: 8),

                      BindPaymentTextFieldCard(
                        controller: _upiController,
                        hintText: 'e.g. 919835913180@ybl',
                        prefixIcon: LucideIcons.badgeCheck,
                        validator: Validators.validateUpi,
                        isDark: isDark,
                        accentColor: _providerAccentColor,
                        onClear: () => _upiController.clear(),
                      )
                          .animate()
                          .fadeIn(delay: 320.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 320.ms),

                      const SizedBox(height: 12),

                      // Quick UPI Handle Pills
                      BindPaymentHandlesBar(
                        onSelectHandle: _appendUpiHandle,
                        isDark: isDark,
                      ).animate().fadeIn(delay: 360.ms, duration: 380.ms),

                      const SizedBox(height: 22),

                      // Security Checklist Card
                      BindPaymentChecklistCard(isDark: isDark)
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 400.ms),

                      const SizedBox(height: 24),

                      // Glowing 3D Verification Action Button
                      BindPaymentActionButton(
                        isLoading: _isLoading,
                        onTap: _handleSave,
                        providerName: _selectedProviderName,
                        primaryColor: _providerPrimaryColor,
                        accentColor: _providerAccentColor,
                      )
                          .animate()
                          .fadeIn(delay: 460.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 460.ms),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
