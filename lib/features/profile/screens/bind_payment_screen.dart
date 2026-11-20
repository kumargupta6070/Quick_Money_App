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
              _buildHeroHeader(context, isDark)
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
                      _buildGuaranteeBanner(isDark)
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

                      // Exclusive PhonePe Provider Card (Single active provider per client requirement)
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF26103D),
                                        const Color(0xFF170826),
                                      ]
                                    : [
                                        const Color(0xFFFAF5FF),
                                        const Color(0xFFF3E8FF),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF9333EA)
                                    .withValues(alpha: isDark ? 0.6 : 0.45),
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9333EA)
                                      .withValues(alpha: isDark ? 0.25 : 0.12),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF6B21A8),
                                        Color(0xFF9333EA),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'पे',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 2,
                                        children: [
                                          Text(
                                            'PhonePe Direct',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5.5,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(0xFF10B981)
                                                    .withValues(alpha: 0.4),
                                              ),
                                            ),
                                            child: Text(
                                              'OFFICIAL PARTNER',
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w900,
                                                color: const Color(0xFF10B981),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '100% Automated ₹100 profit auto-return settlement',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    LucideIcons.check,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 180.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 180.ms),

                      const SizedBox(height: 22),

                      // Account Holder Name Input Field Header
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

                      _buildTextFieldCard(
                            controller: _nameController,
                            hintText: 'e.g. Primary PhonePe Wallet / Full Name',
                            prefixIcon: LucideIcons.user,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Account holder name is required'
                                : null,
                            isDark: isDark,
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

                      _buildTextFieldCard(
                            controller: _upiController,
                            hintText: 'e.g. 919835913180@ybl',
                            prefixIcon: LucideIcons.badgeCheck,
                            validator: Validators.validateUpi,
                            isDark: isDark,
                            onClear: () => _upiController.clear(),
                          )
                          .animate()
                          .fadeIn(delay: 320.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 320.ms),

                      const SizedBox(height: 12),

                      // Quick UPI Handle Pills (One-touch Handle Insertion)
                      Row(
                        children: [
                          Text(
                            'Quick Handles:',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _buildHandleChip(
                                    '@ybl',
                                    const Color(0xFF6B21A8),
                                    isDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildHandleChip(
                                    '@ibl',
                                    const Color(0xFF7C3AED),
                                    isDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildHandleChip(
                                    '@axl',
                                    const Color(0xFF0284C7),
                                    isDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildHandleChip(
                                    '@okhdfcbank',
                                    const Color(0xFF1A73E8),
                                    isDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildHandleChip(
                                    '@paytm',
                                    const Color(0xFF00BAF2),
                                    isDark,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 360.ms, duration: 380.ms),

                      const SizedBox(height: 22),

                      // Bank-Grade Security & Speed Architecture Card
                      Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF0C1935),
                                        const Color(0xFF081226),
                                      ]
                                    : [
                                        const Color(0xFFF8FAFC),
                                        const Color(0xFFF1F5F9),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : const Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.25 : 0.04,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildChecklistItem(
                                  icon: LucideIcons.zap,
                                  iconColor: const Color(0xFFF59E0B),
                                  title: 'Instant Automated PhonePe Remittance',
                                  subtitle: 'Profits auto-transferred as soon as ₹100 threshold is reached.',
                                  isDark: isDark,
                                ),
                                const Divider(height: 18),
                                _buildChecklistItem(
                                  icon: LucideIcons.badgePercent,
                                  iconColor: const Color(0xFF10B981),
                                  title: 'Zero Gateway Deductions (100% Free)',
                                  subtitle: 'No withdrawal cuts, administration fees, or payout limits.',
                                  isDark: isDark,
                                ),
                                const Divider(height: 18),
                                _buildChecklistItem(
                                  icon: LucideIcons.shieldCheck,
                                  iconColor: const Color(0xFF06B6D4),
                                  title: 'AES-256 Military Grade Encryption',
                                  subtitle: 'Stored directly in secure hardware enclave token storage.',
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 400.ms),

                      const SizedBox(height: 24),

                      // Glowing 3D Verification & Binding Action Button
                      InkWell(
                            onTap: _isLoading ? null : _handleSave,
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _providerPrimaryColor,
                                    _providerAccentColor,
                                    const Color(0xFF1D4ED8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: _providerPrimaryColor.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  else ...[
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.20,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.shieldCheck,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Verify & Bind $_selectedProviderName Wallet',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
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

  /// Royal FinTech Hero Curved Header with Glowing Back Button & Live Shield
  Widget _buildHeroHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF07112E),
                  const Color(0xFF0D256B),
                  const Color(0xFF133694),
                ]
              : [
                  const Color(0xFF091A4B),
                  const Color(0xFF11359A),
                  const Color(0xFF1849D6),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D256B).withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bind Payment APP',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Automated profit auto-return wallet channel',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.lock, size: 11, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      'AES-256',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ₹100 Auto-Return Guarantee Showcase Card with dynamic color morphing
  Widget _buildGuaranteeBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A103C),
                  const Color(0xFF0F0B26),
                  const Color(0xFF140D2E),
                ]
              : [
                  const Color(0xFF1E1B4B),
                  const Color(0xFF2E1065),
                  const Color(0xFF1E1B4B),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.45 : 0.50),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D28D9).withValues(
              alpha: isDark ? 0.30 : 0.22,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dual-Ring Glowing Shield Emblem
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC084FC).withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF8B5CF6),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.shieldCheck,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '₹100 Auto-Return Guarantee',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'AUTOMATED',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Whenever your cumulative profit reaches ₹100, the system automatically sends funds back to this bound UPI address via $_selectedProviderName.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 3 Pill Feature Highlights
          Row(
            children: [
              _buildGuaranteePill(
                label: 'Min ₹100 Payout',
                icon: LucideIcons.circleDollarSign,
                color: const Color(0xFF34D399),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildGuaranteePill(
                label: 'Zero Delay',
                icon: LucideIcons.zap,
                color: const Color(0xFFFBBF24),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildGuaranteePill(
                label: 'Direct Settlement',
                icon: LucideIcons.checkCheck,
                color: const Color(0xFF60A5FA),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteePill({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sleek Custom Text Form Field Card with Clear button & Glow Focus
  Widget _buildTextFieldCard({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    required bool isDark,
    required VoidCallback onClear,
  }) {
    final hasText = controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A30) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasText
              ? _providerAccentColor.withValues(alpha: isDark ? 0.60 : 0.45)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFCBD5E1)),
          width: hasText ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasText
                ? _providerAccentColor.withValues(alpha: isDark ? 0.20 : 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          prefixIcon: Icon(prefixIcon, size: 18, color: _providerAccentColor),
          suffixIcon: hasText
              ? GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onClear();
                  },
                  child: const Icon(
                    LucideIcons.x,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHandleChip(String handle, Color color, bool isDark) {
    return InkWell(
      onTap: () => _appendUpiHandle(handle),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.18 : 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 5),
            Text(
              handle,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isDark ? color.withValues(alpha: 0.95) : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
