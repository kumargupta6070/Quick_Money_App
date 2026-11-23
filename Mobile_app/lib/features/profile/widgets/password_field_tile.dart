import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Styled text field with tinted background and error display for password dialogues
class PasswordFieldTile extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final Color iconColor;
  final bool isObscured;
  final VoidCallback onToggleVisibility;
  final List<Color> tileBgColors;
  final Color borderColor;
  final bool isDark;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const PasswordFieldTile({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.iconColor,
    required this.isObscured,
    required this.onToggleVisibility,
    required this.tileBgColors,
    required this.borderColor,
    required this.isDark,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final effectiveBorderColor = hasError ? const Color(0xFFEF4444) : borderColor;
    final effectiveBgColors = hasError
        ? (isDark
            ? [const Color(0xFF2B0E14), const Color(0xFF19070B)]
            : [const Color(0xFFFFF1F2), const Color(0xFFFFE4E6)])
        : tileBgColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: effectiveBgColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: effectiveBorderColor.withValues(
                alpha: isDark ? 0.55 : 0.45,
              ),
              width: hasError ? 1.6 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveBorderColor.withValues(
                  alpha: isDark ? 0.20 : 0.08,
                ),
                blurRadius: hasError ? 8 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscured,
            onChanged: onChanged,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                hasError ? LucideIcons.alertCircle : icon,
                size: 18,
                color: hasError ? const Color(0xFFEF4444) : iconColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isObscured ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 17,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  size: 12,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 4),
                Text(
                  errorText!,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
