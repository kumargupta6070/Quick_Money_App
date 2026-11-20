import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/profit_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/wallet_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../../../shared/widgets/animated_counter.dart';
import '../../home/widgets/home_header.dart';

/// Next-Level FinTech Sell RP Screen.
/// Built strictly adhering to the ICU Mobile App visual hierarchy,
/// ambient glow orbs, HomeHeader integration, colorful section backgrounds,
/// staggered entrance animations, and zero-overflow layout.
class SellRpScreen extends ConsumerStatefulWidget {
  const SellRpScreen({super.key});

  @override
  ConsumerState<SellRpScreen> createState() => _SellRpScreenState();
}

class _SellRpScreenState extends ConsumerState<SellRpScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _handleRefresh());
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      ref.read(userProvider.notifier).fetchProfile(),
      ref.read(walletProvider.notifier).fetchWallet(),
      ref.read(profitProvider.notifier).fetchDailyDetails(),
      ref.read(transactionProvider.notifier).fetchTransactions(),
    ]);
    if (mounted) setState(() {});
  }

  String _formatMaskedUpi(String upi) {
    final trimmed = upi.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split('@');
    if (parts.length == 2) {
      final prefix = parts[0];
      final handle = parts[1];
      if (prefix.length <= 3) {
        return '$prefix*****@$handle';
      }
      final visibleStart = prefix.substring(0, 3);
      return '$visibleStart*****@$handle';
    }
    if (trimmed.length <= 4) {
      return '$trimmed*****';
    }
    return '${trimmed.substring(0, 4)}*****';
  }

  void _handleUnbindWallet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF131D38) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Disconnect PhonePe Wallet?',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Your bound PhonePe UPI ID will be removed. Automated profit return payouts will be temporarily paused until you bind a new wallet.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Keep Wallet',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              CustomLoader.showOverlay(
                context,
                message: 'Disconnecting wallet...',
              );
              final success = await ref
                  .read(walletProvider.notifier)
                  .unbindWallet();
              if (!context.mounted) return;
              CustomLoader.dismiss(context);

              if (success) {
                CustomSnackBar.showSuccess(
                  context: context,
                  message: 'PhonePe wallet disconnected successfully.',
                );
              } else {
                CustomSnackBar.showError(
                  context: context,
                  message: 'Could not disconnect wallet. Please try again.',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  void _showAccelerationSheet(
    BuildContext context,
    double userBalance,
    bool isWalletBound,
  ) {
    final progress = (userBalance / 100.0).clamp(0.0, 1.0);
    final remaining = (100.0 - userBalance).clamp(0.0, 100.0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1F0F172A),
              blurRadius: 28,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle Pill
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Modal Header with Glowing Zap Emblem & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.zap,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Sell RP & Acceleration',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.pop(sheetCtx),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dual FinTech Metric Tiles (Balance & Auto-Return Target) - Light Theme & Zero-Overflow
            Row(
              children: [
                // Available Balance Tile (Soft Sky Blue)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFBAE6FD),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7)
                              .withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.wallet,
                              size: 12,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'AVAILABLE BALANCE',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 8.8,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0369A1),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '₹${userBalance.toStringAsFixed(2)}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Auto-Return Target Tile (Soft Emerald)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFA7F3D0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.target,
                              size: 12,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'AUTO-RETURN TARGET',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 8.8,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF047857),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '₹100.00',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // PhonePe Auto-Refund Progress Bar Container (Light Theme)
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PhonePe Settlement Progress',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userBalance >= 100
                        ? '🎉 Target reached! Instant PhonePe payout unlocked.'
                        : '₹${remaining.toStringAsFixed(2)} remaining to trigger instant auto-settlement.',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: userBalance >= 100
                          ? const Color(0xFF059669)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // How It Works - 3 Light Theme Step Cards
            Text(
              'HOW IT WORKS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 8),

            _buildAccelerationStepCard(
              icon: LucideIcons.shoppingBag,
              stepNum: '1',
              title: 'Receive RP Orders',
              subtitle: 'Brokerage profit + daily bonuses credit immediately to your live balance.',
              accentColor: const Color(0xFF0284C7),
              bgColor: const Color(0xFFF0F9FF),
              borderColor: const Color(0xFFBAE6FD),
            ),
            const SizedBox(height: 8),

            _buildAccelerationStepCard(
              icon: LucideIcons.sparkles,
              stepNum: '2',
              title: '₹100 Cumulative Profit Trigger',
              subtitle: 'Reaching ₹100 profit triggers guaranteed zero-fee automated settlement.',
              accentColor: const Color(0xFF059669),
              bgColor: const Color(0xFFECFDF5),
              borderColor: const Color(0xFFA7F3D0),
            ),
            const SizedBox(height: 8),

            _buildAccelerationStepCard(
              icon: LucideIcons.send,
              stepNum: '3',
              title: 'PhonePe Direct UPI Settlement',
              subtitle: 'Funds deposit straight into your bound PhonePe account in minutes.',
              accentColor: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFFAF5FF),
              borderColor: const Color(0xFFE9D5FF),
            ),

            const SizedBox(height: 18),

            // CTA Button
            if (userBalance >= 100 && isWalletBound) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(sheetCtx);
                  CustomLoader.showOverlay(
                    context,
                    message: 'Initiating payout settlement...',
                  );
                  final success = await ref
                      .read(transactionProvider.notifier)
                      .requestPayout(amount: userBalance);
                  if (!context.mounted) return;
                  CustomLoader.dismiss(context);
                  if (success) {
                    CustomSnackBar.showSuccess(
                      context: context,
                      message:
                          'Payout request initiated successfully to PhonePe!',
                    );
                    _handleRefresh();
                  } else {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Could not process payout. Please verify wallet balance.',
                    );
                  }
                },
                icon: const Icon(LucideIcons.arrowUpRight, size: 16),
                label: const Text('Request Instant Cash-out to PhonePe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Got It • Keep Earning',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccelerationStepCard({
    required IconData icon,
    required String stepNum,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: accentColor),
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
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animTrigger = ref.watch(sellRpAnimationTriggerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final wallet = ref.watch(walletProvider);
    final profit = ref.watch(profitProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: AnimatedAmbientBackground(
        child: RefreshIndicator(
          key: ValueKey('sell_refresh_$animTrigger'),
          onRefresh: _handleRefresh,
          color: AppColors.brandPrimary,
          backgroundColor: isDark ? const Color(0xFF131D38) : Colors.white,
          displacement: 40,
          child: CustomScrollView(
            key: ValueKey('sell_scroll_$animTrigger'),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── Section 1: Top FinTech Curved Hero Banner with HomeHeader ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0A1B4B),
                        Color(0xFF143BB8),
                        Color(0xFF0C246E),
                      ],
                      stops: [0.0, 0.65, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0F2B82),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                      child: Column(
                        children: [
                          // HomeHeader Integration (Brand emblem, Market Online, Balance pill & Notifications)
                          HomeHeader(
                            key: ValueKey('sell_home_header_$animTrigger'),
                            balance: user.balance,
                          ),

                          const SizedBox(height: 14),

                          // Subheader Bar: Title & Live Instant Payout Status
                          Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF38BDF8)
                                                .withValues(alpha: 0.20),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            LucideIcons.arrowUpRight,
                                            size: 14,
                                            color: Color(0xFF38BDF8),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            'SELL RP & CASH-OUT',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.8,
                                              color: Colors.white.withValues(
                                                alpha: 0.95,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.35),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF10B981),
                                              ),
                                            )
                                            .animate(
                                              onPlay: (c) =>
                                                  c.repeat(reverse: true),
                                            )
                                            .fade(
                                              begin: 0.3,
                                              end: 1.0,
                                              duration: 500.ms,
                                            ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'PhonePe Auto-Return',
                                          style: GoogleFonts.inter(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF34D399),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                              .animate()
                              .fade(duration: 350.ms)
                              .slideY(begin: 0.1, end: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Section 2: Staggered Animated Content Body ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 1. Today's Overview Card (Colorful Sky/Blue FinTech Gradient) ──
                      _buildOverviewCard(
                        context: context,
                        isDark: isDark,
                        receiptAmount: profit.sellAmount,
                        animIndex: 1,
                      ),

                      const SizedBox(height: 14),

                      // ── 2. USDT Crypto Top-Up Tutorial Banner ──
                      _buildUsdtTutorialBanner(context: context, animIndex: 2),

                      const SizedBox(height: 20),

                      // ── 3. Wallet Information Section Header ──
                      Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF5F259F)
                                            .withValues(
                                              alpha: isDark ? 0.35 : 0.15,
                                            ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        LucideIcons.wallet,
                                        size: 15,
                                        color: Color(0xFF8B5CF6),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Wallet Information',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Acceleration Rules Help Link
                              InkWell(
                                onTap: () => _showAccelerationSheet(
                                  context,
                                  user.balance,
                                  wallet.isBound,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.helpCircle,
                                        size: 13,
                                        color: isDark
                                            ? const Color(0xFF38BDF8)
                                            : AppColors.brandPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Acceleration rules',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? const Color(0xFF38BDF8)
                                              : AppColors.brandPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fade(delay: 150.ms, duration: 350.ms)
                          .slideX(begin: -0.05, end: 0),

                      const SizedBox(height: 10),

                      // ── 4. Bound Wallet Card (Live Backend Sync) ──
                      if (wallet.isBound)
                        _buildBoundWalletCard(
                          context: context,
                          isDark: isDark,
                          wallet: wallet,
                          animIndex: 3,
                        )
                      else
                        _buildEmptyWalletCard(
                          context: context,
                          isDark: isDark,
                          animIndex: 3,
                        ),

                      const SizedBox(height: 16),

                      // ── 5. Action Buttons: [+ Add / Change Wallet] & [Sell Faster] ──
                      _buildActionGrid(
                        context: context,
                        isDark: isDark,
                        isWalletBound: wallet.isBound,
                        userBalance: user.balance,
                        animIndex: 4,
                      ),
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

  /// 1. Today's Overview Card with Sky/Cyan FinTech Gradient Background
  Widget _buildOverviewCard({
    required BuildContext context,
    required bool isDark,
    required double receiptAmount,
    required int animIndex,
  }) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF132347), const Color(0xFF0C1730)]
                  : [const Color(0xFFEFF8FF), const Color(0xFFE0F2FE)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.35)
                  : const Color(0xFF38BDF8).withValues(alpha: 0.40),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7)
                    .withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Pill: Today's Overview with Lucide icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0284C7).withValues(alpha: 0.25)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.30),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.calendarClock,
                          size: 13,
                          color: Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Today's Overview",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : AppColors.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Guaranteed Payout Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.shieldCheck,
                          size: 11,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Direct Auto-Return',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Amount of Receipt & Record Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount of receipt:',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : AppColors.brandPrimary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: AnimatedCounter(
                                  value: receiptAmount,
                                  decimalDigits: 2,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 3D "Record" Button
                  GestureDetector(
                    onTap: () => context.push('/transactions'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB)
                                .withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.history,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Record',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 60 * animIndex))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// 2. USDT Crypto Top-Up Tutorial Banner with Deep Ocean / Emerald Gradient
  Widget _buildUsdtTutorialBanner({
    required BuildContext context,
    required int animIndex,
  }) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF052E26), Color(0xFF0F766E), Color(0xFF0284C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D9488).withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Glowing Tether Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26A17B), Color(0xFF147D5E)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF26A17B).withValues(alpha: 0.50),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '₮',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USDT Top-up Tutorial',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Safe & secure cryptocurrency recharge',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // "Check >" Pill Button
              InkWell(
                onTap: () {
                  CustomSnackBar.showInfo(
                    context: context,
                    message: 'USDT (TRC-20) tutorial: Fast, zero-fee crypto recharge with instant exchange credit.',
                    icon: LucideIcons.coins,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Check',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: Colors.white,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 60 * animIndex))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// 3A. Empty State when No PhonePe Wallet is Bound
  Widget _buildEmptyWalletCard({
    required BuildContext context,
    required bool isDark,
    required int animIndex,
  }) {
    return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E173D), const Color(0xFF140F2C)]
                  : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF8B5CF6)
                  .withValues(alpha: isDark ? 0.35 : 0.30),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6)
                    .withValues(alpha: isDark ? 0.20 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5F259F), Color(0xFF451978)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5F259F)
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'पे',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No PhonePe Wallet Linked',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Link your UPI ID to enable automated ₹100 profit returns directly to your bank account.',
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
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/bind-payment'),
                  icon: const Icon(LucideIcons.plus, size: 15),
                  label: const Text('Bind PhonePe Direct'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F259F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 60 * animIndex))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// 3B. Bound Wallet Card with PhonePe Purple Background & Live Backend Status Details
  Widget _buildBoundWalletCard({
    required BuildContext context,
    required bool isDark,
    required WalletModel wallet,
    required int animIndex,
  }) {
    final isVerified = wallet.status == WalletStatus.active;
    final isAbnormal = wallet.status == WalletStatus.abnormal;

    final statusColor = isVerified
        ? const Color(0xFF10B981)
        : (isAbnormal ? const Color(0xFFEF4444) : const Color(0xFFD97706));

    final statusLabel = isVerified
        ? 'Verified & Active'
        : (isAbnormal ? 'UPI Abnormal' : 'Verification Required');

    final statusIcon = isVerified
        ? LucideIcons.shieldCheck
        : (isAbnormal
              ? LucideIcons.alertTriangle
              : Icons.warning_amber_rounded);

    final detailText = wallet.statusDetail?.isNotEmpty == true
        ? wallet.statusDetail!
        : (isVerified ? 'Verified via NPCI Bank Gateway' : 'Action Required');

    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E173D), const Color(0xFF140F2C)]
                  : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF8B5CF6)
                  .withValues(alpha: isDark ? 0.35 : 0.30),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6)
                    .withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PhonePe Icon (Purple square with 'पे')
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5F259F), Color(0xFF451978)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5F259F)
                              .withValues(alpha: 0.40),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'पे',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Wallet details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                wallet.paymentApp.toLowerCase() == 'phonepe'
                                    ? 'PhonePe Direct'
                                    : wallet.paymentApp.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
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
                                color: const Color(0xFF5F259F)
                                    .withValues(alpha: isDark ? 0.30 : 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'DEFAULT UPI',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'UPI: ${_formatMaskedUpi(wallet.upiId)}',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Dynamic Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 13, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Red outlined Disconnect button
                  OutlinedButton(
                    onPressed: () => _handleUnbindWallet(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.2,
                      ),
                      foregroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      'Disconnect',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 10),

              // Detail & View Details Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isVerified
                              ? LucideIcons.checkCircle2
                              : LucideIcons.alertCircle,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Detail: $detailText',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.push('/bind-payment'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : AppColors.brandPrimary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 13,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : AppColors.brandPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 60 * animIndex))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// 4. Action Grid: [+ Add / Change Wallet] and [Sell Faster] with Distinct FinTech Themes
  Widget _buildActionGrid({
    required BuildContext context,
    required bool isDark,
    required bool isWalletBound,
    required double userBalance,
    required int animIndex,
  }) {
    return Row(
          children: [
            // 1. Add / Change Wallet Card (Royal Blue FinTech Theme)
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/bind-payment'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF132347), const Color(0xFF0C1730)]
                          : [const Color(0xFFEFF8FF), const Color(0xFFE0F2FE)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.35)
                          : const Color(0xFF38BDF8).withValues(alpha: 0.40),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7)
                            .withValues(alpha: isDark ? 0.25 : 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2563EB),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isWalletBound
                              ? LucideIcons.arrowLeftRight
                              : Icons.add,
                          size: 19,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isWalletBound ? 'Manage Wallet' : 'Add Wallet',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isWalletBound
                            ? 'Update UPI account'
                            : 'Link new UPI account',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // 2. Sell Faster Card (Amber Gold FinTech Theme)
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    _showAccelerationSheet(context, userBalance, isWalletBound),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF2C200E), const Color(0xFF1E1508)]
                          : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFD97706)
                          .withValues(alpha: isDark ? 0.38 : 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD97706)
                            .withValues(alpha: isDark ? 0.25 : 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFF59E0B),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.zap,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sell Faster',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PhonePe Direct Payout',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
        .animate(delay: Duration(milliseconds: 60 * animIndex))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
