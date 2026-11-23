import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FinTech Input Card for Platform Rules & Config
class AdminSettingsFieldCard extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool isDark;
  final Color? accentColor;
  final bool isNumber;

  const AdminSettingsFieldCard({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.isDark,
    this.accentColor,
    this.isNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark
            ? Color.alphaBlend(effectiveAccent.withValues(alpha: 0.06), const Color(0xFF1E293B))
            : Color.alphaBlend(effectiveAccent.withValues(alpha: 0.04), Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: effectiveAccent.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveAccent.withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: effectiveAccent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
