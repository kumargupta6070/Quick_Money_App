import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/core/providers/order_provider.dart';
import 'package:quick_money/core/theme/app_colors.dart';
import 'package:quick_money/core/utils/custom_loader.dart';
import 'package:quick_money/core/utils/custom_snackbar.dart';
import 'package:quick_money/shared/models/order_model.dart';

class BuyRpReceiveOrderDialog extends ConsumerWidget {
  final OrderModel order;
  final bool isDark;

  const BuyRpReceiveOrderDialog({
    super.key,
    required this.order,
    required this.isDark,
  });

  static void show(
    BuildContext context, {
    required OrderModel order,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BuyRpReceiveOrderDialog(
        order: order,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountStr = order.orderAmount.truncateToDouble() == order.orderAmount
        ? order.orderAmount.toInt().toString()
        : order.orderAmount.toStringAsFixed(2);
    final rewardStr = order.reward.truncateToDouble() == order.reward
        ? order.reward.toInt().toString()
        : order.reward.toStringAsFixed(2);
    final bonusStr = order.bonus.truncateToDouble() == order.bonus
        ? order.bonus.toInt().toString()
        : order.bonus.toStringAsFixed(1);
    final finalRpStr = order.finalRp.truncateToDouble() == order.finalRp
        ? order.finalRp.toInt().toString()
        : order.finalRp.toStringAsFixed(1);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF142347), const Color(0xFF0A1428)]
                : [
                    const Color(0xFFE2F0FD),
                    const Color(0xFFEBF5FE),
                    const Color(0xFFF0F7FF),
                  ],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isDark
                ? const Color(0xFF38BDF8).withValues(alpha: 0.45)
                : const Color(0xFF0284C7).withValues(alpha: 0.50),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7)
                  .withValues(alpha: isDark ? 0.45 : 0.20),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0284C7),
                            Color(0xFF2563EB),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7)
                                .withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.shoppingBag,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receive Order',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Review earnings & auto-return',
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
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.x, size: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Highlighted Investment Hero Pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E2E5A),
                          const Color(0xFF131D38),
                        ]
                      : [
                          const Color(0xFFE0F2FE),
                          const Color(0xFFF0FDF4),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVESTMENT AMOUNT',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF0369A1),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹$amountStr',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7)
                          .withValues(alpha: isDark ? 0.30 : 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.40),
                      ),
                    ),
                    child: Text(
                      '${order.level} Tier',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Breakdown Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF0F1A33),
                          const Color(0xFF091224),
                        ]
                      : [Colors.white, const Color(0xFFF0FDF4)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.20)
                      : const Color(0xFF0284C7).withValues(alpha: 0.25),
                  width: 1.1,
                ),
              ),
              child: Column(
                children: [
                  _buildDialogRow(
                    'Brokerage Reward',
                    '+₹$rewardStr',
                    isDark,
                    icon: LucideIcons.gift,
                    color: const Color(0xFFD97706),
                  ),
                  const Divider(height: 18),
                  _buildDialogRow(
                    'Special Bonus',
                    '+₹$bonusStr',
                    isDark,
                    icon: LucideIcons.sparkle,
                    color: const Color(0xFF10B981),
                  ),
                  const Divider(height: 18),
                  _buildDialogRow(
                    'Final Credited RP',
                    '$finalRpStr RP',
                    isDark,
                    isBold: true,
                    icon: LucideIcons.sparkles,
                    color: const Color(0xFF059669),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // PhonePe Auto-Return Information Banner
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1)
                    .withValues(alpha: isDark ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.28),
                  width: 0.9,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF5F259F),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'पे',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Automatic PhonePe Return: When cumulative profit hits ₹100, capital + profits auto-transfer to your PhonePe account.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFA5B4FC)
                            : const Color(0xFF4338CA),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white30
                            : const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      CustomLoader.showOverlay(
                        context,
                        message:
                            'Reserving Order & Crediting RP on Live Gateway...',
                      );

                      final result = await ref
                          .read(orderProvider.notifier)
                          .receiveOrder(order.id);

                      if (!context.mounted) return;
                      CustomLoader.dismiss(context);

                      if (result.success) {
                        CustomSnackBar.showSuccess(
                          context: context,
                          message: result.message,
                          icon: Icons.check_circle_rounded,
                        );
                      } else {
                        CustomSnackBar.showError(
                          context: context,
                          message: result.message,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm Order',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.arrowRight, size: 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.90, 0.90),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
          duration: 350.ms,
        )
        .fadeIn(duration: 350.ms);
  }

  Widget _buildDialogRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    Color? color,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: color ??
                    (isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.5,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
                color:
                    color ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
