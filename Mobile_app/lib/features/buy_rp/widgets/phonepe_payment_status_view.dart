import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/currency_formatter.dart';

enum PaymentStep { initiating, awaiting, success, failed }

/// Status indicator graphic and messaging for PhonePe checkout
class PhonePePaymentStatusView extends StatelessWidget {
  final PaymentStep step;
  final bool isDark;
  final double orderAmount;
  final String statusMessage;

  const PhonePePaymentStatusView({
    super.key,
    required this.step,
    required this.isDark,
    required this.orderAmount,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case PaymentStep.initiating:
        return Column(
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                color: Color(0xFF5F259F),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ],
        );
      case PaymentStep.awaiting:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF5F259F)
                    .withValues(alpha: isDark ? 0.20 : 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.smartphone,
                size: 34,
                color: Color(0xFF7B2CBF),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                ),
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.format(orderAmount),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        );
      case PaymentStep.success:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.check,
                size: 36,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 12),
            Text(
              'Payment Successful!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.grey),
            ),
          ],
        );
      case PaymentStep.failed:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Payment Failed',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
    }
  }
}
