import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bank-Grade Security & Speed Architecture Card with Checklist
class BindPaymentChecklistCard extends StatelessWidget {
  final bool isDark;

  const BindPaymentChecklistCard({super.key, required this.isDark});

  Widget _buildChecklistItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0C1935), const Color(0xFF081226)]
              : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildChecklistItem(
            icon: LucideIcons.zap,
            iconColor: const Color(0xFFF59E0B),
            title: 'Instant Automated PhonePe Remittance',
            subtitle: 'Profits auto-transferred as soon as ₹100 threshold is reached.',
            isDark: isDark,
          ),
          const Divider(height: 18),
          _buildChecklistItem(
            icon: LucideIcons.badgePercent,
            iconColor: const Color(0xFF10B981),
            title: 'Zero Gateway Deductions (100% Free)',
            subtitle: 'No withdrawal cuts, administration fees, or payout limits.',
            isDark: isDark,
          ),
          const Divider(height: 18),
          _buildChecklistItem(
            icon: LucideIcons.shieldCheck,
            iconColor: const Color(0xFF06B6D4),
            title: 'AES-256 Military Grade Encryption',
            subtitle: 'Stored directly in secure hardware enclave token storage.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
