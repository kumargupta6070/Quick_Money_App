import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/widgets/animated_counter.dart';

class ProfileBalanceCard extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const ProfileBalanceCard({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF132247),
                  const Color(0xFF0C1630),
                  const Color(0xFF162854),
                ]
              : [
                  const Color(0xFFEFF8FF),
                  const Color(0xFFE0F2FE),
                  const Color(0xFFF0FDF4),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF38BDF8).withValues(alpha: 0.35)
              : const Color(0xFF0284C7).withValues(alpha: 0.30),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/daily-details');
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header: Label + Financial Details link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.sparkles,
                            size: 13,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CURRENT AVAILABLE BALANCE',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Details',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          LucideIcons.chevronRight,
                          size: 13,
                          color: Color(0xFF0284C7),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Animated Balance Display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedCounter(
                          value: user.balance,
                          decimalDigits: 2,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick Action Buttons (Deposit / Withdraw)
                Row(
                  children: [
                    // Deposit Funds Button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.go('/buy-rp');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.arrowDownToLine, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Deposit Funds',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Withdraw / Sell Button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.go('/sell-rp');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.arrowUpFromLine, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Withdraw / Sell',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Guarantee footer pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.shieldCheck, size: 13, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'PhonePe Gateway Auto-Return active on orders reaching ₹100 profit.',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
