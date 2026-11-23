import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/core/utils/custom_snackbar.dart';

class SellRpUsdtBanner extends StatelessWidget {
  final int animIndex;

  const SellRpUsdtBanner({super.key, this.animIndex = 2});

  @override
  Widget build(BuildContext context) {
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
                message:
                    'USDT (TRC-20) tutorial: Fast, zero-fee crypto recharge with instant exchange credit.',
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
}
