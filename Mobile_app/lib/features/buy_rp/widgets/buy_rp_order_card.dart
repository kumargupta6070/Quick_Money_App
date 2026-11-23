import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/shared/models/order_model.dart';

class BuyRpOrderCard extends StatelessWidget {
  final OrderModel order;
  final int index;
  final bool isDark;
  final VoidCallback onReceive;

  const BuyRpOrderCard({
    super.key,
    required this.order,
    required this.index,
    required this.isDark,
    required this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    final cardThemes = [
      {
        'accent': const Color(0xFF0284C7),
        'lightColors': [const Color(0xFFEFF8FF), const Color(0xFFE2F0FE)],
        'darkColors': [const Color(0xFF102544), const Color(0xFF0B192E)],
        'borderColor': const Color(0xFF38BDF8),
      },
      {
        'accent': const Color(0xFF059669),
        'lightColors': [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
        'darkColors': [const Color(0xFF0E2C20), const Color(0xFF091F17)],
        'borderColor': const Color(0xFF34D399),
      },
      {
        'accent': const Color(0xFFD97706),
        'lightColors': [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
        'darkColors': [const Color(0xFF2E210E), const Color(0xFF201608)],
        'borderColor': const Color(0xFFFBBF24),
      },
      {
        'accent': const Color(0xFF4F46E5),
        'lightColors': [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
        'darkColors': [const Color(0xFF1C194D), const Color(0xFF131036)],
        'borderColor': const Color(0xFF818CF8),
      },
    ];

    final theme = cardThemes[index % cardThemes.length];
    final accentColor = theme['accent'] as Color;
    final bgColors = isDark
        ? (theme['darkColors'] as List<Color>)
        : (theme['lightColors'] as List<Color>);
    final borderColor = theme['borderColor'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgColors,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor.withValues(alpha: isDark ? 0.38 : 0.32),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Tier Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(
                            alpha: isDark ? 0.30 : 0.16,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: borderColor.withValues(alpha: 0.45),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          order.level,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? borderColor : accentColor,
                          ),
                        ),
                      ),

                      // PhonePe Guaranteed Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: isDark ? 0.22 : 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.30),
                            width: 0.8,
                          ),
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
                              'PhonePe Guaranteed',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Final RP Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981)
                        .withValues(alpha: isDark ? 0.24 : 0.16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.40),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.sparkles,
                        size: 11,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Final: ${order.finalRp} RP',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Card Middle Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? borderColor : accentColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${order.orderAmount}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Order Amount',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.layers,
                            size: 13,
                            color: isDark ? borderColor : accentColor,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Available: ${order.orderQuantity} orders',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onReceive,
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
                          color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Receive',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          LucideIcons.arrowRight,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Card Bottom Strip
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.gift,
                        size: 11,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reward: ₹${order.reward}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981)
                        .withValues(alpha: isDark ? 0.25 : 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.40),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.sparkle,
                        size: 10,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '+₹${order.bonus} Bonus',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1)
                        .withValues(alpha: isDark ? 0.20 : 0.14),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.30),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.repeat,
                        size: 10,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Auto-return upon ₹100 Profit',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFA5B4FC)
                              : const Color(0xFF4338CA),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 65 * index))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.10,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        )
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1.0, 1.0),
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }
}
