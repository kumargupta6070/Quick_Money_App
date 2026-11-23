import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/core/utils/custom_snackbar.dart';
import 'package:quick_money/features/notification/models/notification_model.dart';
import 'package:quick_money/features/notification/providers/notification_provider.dart';
import 'package:quick_money/features/notification/widgets/notification_type_config.dart';

class NotificationDetailModal extends ConsumerWidget {
  final NotificationModel item;
  final bool isDark;

  const NotificationDetailModal({
    super.key,
    required this.item,
    required this.isDark,
  });

  static void show(
    BuildContext context, {
    required NotificationModel item,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => NotificationDetailModal(
        item: item,
        isDark: isDark,
      ),
    );
  }

  String _formatDetailedDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeConfig = NotificationTypeConfig.fromType(item.type, isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: typeConfig.modalGradient,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: typeConfig.accentColor.withValues(
              alpha: isDark ? 0.55 : 0.45,
            ),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: typeConfig.accentColor.withValues(
                alpha: isDark ? 0.40 : 0.25,
              ),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: typeConfig.gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: typeConfig.accentColor.withValues(
                              alpha: 0.45,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        typeConfig.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeConfig.accentColor.withValues(
                          alpha: isDark ? 0.30 : 0.16,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: typeConfig.accentColor.withValues(
                            alpha: 0.40,
                          ),
                        ),
                      ),
                      child: Text(
                        typeConfig.label.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? typeConfig.accentColor
                              : typeConfig.gradientColors.first,
                        ),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.x, size: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Title
            Text(
              item.title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 6),

            // Timestamp
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDetailedDate(item.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Credited Amount Hero Box
            if (item.amount != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.sparkles,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CREDITED AMOUNT',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            Text(
                              'Instant Wallet Addition',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '+₹${item.amount!.toStringAsFixed(2)}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Message Body
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                item.detailedMessage,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Security Guarantee Pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.shieldCheck,
                    size: 13,
                    color: Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Verified & Protected under Quick Money FinTech Protocol.',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0369A1),
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
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(notificationProvider.notifier)
                          .markAsUnread(item.id);
                      Navigator.pop(context);
                      CustomSnackBar.showInfo(
                        context: context,
                        message: 'Marked as unread.',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Mark Unread',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      if (item.actionRoute != null) {
                        final route = item.actionRoute!;
                        if (route == '/sell-rp' ||
                            route == '/buy-rp' ||
                            route == '/home' ||
                            route == '/profile') {
                          context.go(route);
                        } else {
                          context.push(route);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: typeConfig.gradientColors.first,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                      shadowColor: typeConfig.accentColor.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            item.actionLabel ?? 'Got It',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.arrowRight, size: 14),
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
          begin: const Offset(0.88, 0.88),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 250.ms);
  }
}
