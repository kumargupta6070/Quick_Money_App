import 'package:flutter/material.dart';

/// Reusable modern frosted glass capsule badge with glowing status dot.
class GlassCapsuleBadge extends StatelessWidget {
  final String label;
  final Color dotColor;
  final Color borderColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const GlassCapsuleBadge({
    super.key,
    required this.label,
    this.dotColor = const Color(0xFF10B981),
    this.borderColor = const Color(0xFF00E5FF),
    this.textColor = const Color(0xFFE2E8F0),
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: [
                BoxShadow(
                  color: dotColor,
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

