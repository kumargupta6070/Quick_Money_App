import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/core/theme/app_colors.dart';

class BuyRpControlBar extends StatelessWidget {
  final bool isDark;
  final String sortOrder;
  final VoidCallback onToggleSort;
  final VoidCallback onRefresh;
  final AnimationController refreshRotController;

  const BuyRpControlBar({
    super.key,
    required this.isDark,
    required this.sortOrder,
    required this.onToggleSort,
    required this.onRefresh,
    required this.refreshRotController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF142347), const Color(0xFF0F1A35)]
              : [const Color(0xFFEBF3FE), const Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF38BDF8).withValues(alpha: 0.22)
              : const Color(0xFF38BDF8).withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7)
                .withValues(alpha: isDark ? 0.20 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Sort Toggle Pill
          Expanded(
            child: InkWell(
              onTap: onToggleSort,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7)
                      .withValues(alpha: isDark ? 0.24 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.30),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sortOrder == 'low_to_high'
                          ? LucideIcons.arrowUpNarrowWide
                          : LucideIcons.arrowDownWideNarrow,
                      size: 13,
                      color: isDark
                          ? const Color(0xFF38BDF8)
                          : AppColors.brandPrimary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        sortOrder == 'low_to_high'
                            ? 'Low to High'
                            : 'High to Low',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // 2. Exchange Rate Pill with Amber Background
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706)
                  .withValues(alpha: isDark ? 0.24 : 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD97706).withValues(alpha: 0.32),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.zap,
                  size: 11,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 3),
                Text(
                  '1 RP = ₹1',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // 3. Animated Refresh Button
          InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981)
                    .withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.30),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: refreshRotController,
                    child: Icon(
                      LucideIcons.rotateCcw,
                      size: 12,
                      color: isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Refresh',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 350.ms).slideY(begin: 0.08, end: 0);
  }
}
