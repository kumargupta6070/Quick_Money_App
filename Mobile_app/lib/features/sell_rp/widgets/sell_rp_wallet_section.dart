import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/core/providers/wallet_provider.dart';
import 'package:quick_money/core/theme/app_colors.dart';
import 'package:quick_money/core/utils/custom_loader.dart';
import 'package:quick_money/core/utils/custom_snackbar.dart';
import 'package:quick_money/features/sell_rp/widgets/sell_rp_action_grid.dart';
import 'package:quick_money/features/sell_rp/widgets/sell_rp_bound_wallet_card.dart';

class SellRpWalletSection extends ConsumerWidget {
  final bool isDark;
  final WalletModel wallet;
  final double userBalance;
  final VoidCallback onOpenAcceleration;

  const SellRpWalletSection({
    super.key,
    required this.isDark,
    required this.wallet,
    required this.userBalance,
    required this.onOpenAcceleration,
  });

  void _handleUnbindWallet(BuildContext context, WidgetRef ref) {
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
              final success =
                  await ref.read(walletProvider.notifier).unbindWallet();
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Wallet Information Section Header
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
                          .withValues(alpha: isDark ? 0.35 : 0.15),
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
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onOpenAcceleration,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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

        // Wallet Card (Bound or Empty)
        if (wallet.isBound)
          SellRpBoundWalletCard(
            isDark: isDark,
            wallet: wallet,
            onDisconnect: () => _handleUnbindWallet(context, ref),
          )
              .animate(delay: 180.ms)
              .fadeIn(duration: 350.ms, curve: Curves.easeOut)
              .slideY(begin: 0.10, end: 0, curve: Curves.easeOutCubic)
        else
          _buildEmptyWalletCard(context)
              .animate(delay: 180.ms)
              .fadeIn(duration: 350.ms, curve: Curves.easeOut)
              .slideY(begin: 0.10, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 16),

        // Action Grid: [+ Add / Change Wallet] & [Sell Faster]
        SellRpActionGrid(
          isDark: isDark,
          isWalletBound: wallet.isBound,
          onOpenAcceleration: onOpenAcceleration,
        )
            .animate(delay: 240.ms)
            .fadeIn(duration: 350.ms, curve: Curves.easeOut)
            .slideY(begin: 0.10, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildEmptyWalletCard(BuildContext context) {
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
          color:
              const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.35 : 0.30),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.20 : 0.08),
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
                      color: const Color(0xFF5F259F).withValues(alpha: 0.35),
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
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
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
    );
  }
}
