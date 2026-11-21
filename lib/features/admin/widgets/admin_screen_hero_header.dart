import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/widgets/home_header.dart';

/// Signature FinTech Hero Header for Super Admin Screens.
/// Imports and unifies HomeHeader (brand emblem, live status pulse, lightning pill & notifications),
/// with royal sapphire gradient, rounded bottom corners, customizable sub-bar and actions.
class AdminScreenHeroHeader extends ConsumerWidget {
  final String title;
  final IconData icon;
  final String badgeText;
  final Color? badgeColor;
  final Widget? trailing;
  final Widget? bottom;
  final double? balance;

  const AdminScreenHeroHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.badgeText,
    this.badgeColor,
    this.trailing,
    this.bottom,
    this.balance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveBadgeColor = badgeColor ?? const Color(0xFF10B981);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF07112E),
            Color(0xFF0F2B82),
            Color(0xFF1A44B8),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07112E),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Signature Unified HomeHeader (Live Amount Pill hidden for admin)
              HomeHeader(balance: balance, showBalance: false),

              const SizedBox(height: 14),

              // 2. Dynamic Super Admin Subheader Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Icon(icon, size: 14, color: const Color(0xFF38BDF8)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // Status Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: effectiveBadgeColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: effectiveBadgeColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: effectiveBadgeColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              badgeText,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: effectiveBadgeColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (trailing != null) ...[
                        const SizedBox(width: 8),
                        trailing!,
                      ],
                    ],
                  ),
                ],
              ),

              if (bottom != null) ...[
                const SizedBox(height: 12),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
