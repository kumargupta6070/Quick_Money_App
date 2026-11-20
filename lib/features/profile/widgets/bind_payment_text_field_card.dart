import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Sleek Custom Text Form Field Card with Clear button & Glow Focus
class BindPaymentTextFieldCard extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onClear;

  const BindPaymentTextFieldCard({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    required this.isDark,
    required this.accentColor,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A30) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasText
              ? accentColor.withValues(alpha: isDark ? 0.60 : 0.45)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFCBD5E1)),
          width: hasText ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasText
                ? accentColor.withValues(alpha: isDark ? 0.20 : 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          prefixIcon: Icon(prefixIcon, size: 18, color: accentColor),
          suffixIcon: hasText
              ? GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onClear();
                  },
                  child: const Icon(
                    LucideIcons.x,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
