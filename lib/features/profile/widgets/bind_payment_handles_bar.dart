import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One-touch Quick UPI Handles Bar
class BindPaymentHandlesBar extends StatelessWidget {
  final ValueChanged<String> onSelectHandle;
  final bool isDark;

  const BindPaymentHandlesBar({
    super.key,
    required this.onSelectHandle,
    required this.isDark,
  });

  Widget _buildHandleChip(String handle, Color color) {
    return InkWell(
      onTap: () => onSelectHandle(handle),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.18 : 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 5),
            Text(
              handle,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isDark ? color.withValues(alpha: 0.95) : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Quick Handles:',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildHandleChip('@ybl', const Color(0xFF6B21A8)),
                const SizedBox(width: 6),
                _buildHandleChip('@ibl', const Color(0xFF7C3AED)),
                const SizedBox(width: 6),
                _buildHandleChip('@axl', const Color(0xFF0284C7)),
                const SizedBox(width: 6),
                _buildHandleChip('@okhdfcbank', const Color(0xFF1A73E8)),
                const SizedBox(width: 6),
                _buildHandleChip('@paytm', const Color(0xFF00BAF2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
