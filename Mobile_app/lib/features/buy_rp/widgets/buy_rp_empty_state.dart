import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/core/theme/app_colors.dart';

class BuyRpEmptyState extends StatelessWidget {
  final bool isDark;
  final String level;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const BuyRpEmptyState({
    super.key,
    required this.isDark,
    required this.level,
    this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (hasError ? Colors.red : const Color(0xFF0284C7))
                    .withValues(alpha: 0.15),
                border: Border.all(
                  color: (hasError ? Colors.red : const Color(0xFF0284C7))
                      .withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  hasError
                      ? LucideIcons.alertTriangle
                      : LucideIcons.packageOpen,
                  size: 32,
                  color: hasError ? Colors.red : const Color(0xFF0284C7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasError ? 'Connection Notice' : 'No Orders in Tier $level',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasError
                  ? errorMessage!
                  : 'All current orders in $level are currently fulfilled. Switch tiers or refresh to check updated market listings.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(LucideIcons.rotateCcw, size: 14),
              label: Text(hasError ? 'Retry' : 'Refresh Orders'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1));
  }
}
