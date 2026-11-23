import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Pill badge for Level (L1-L7), Warning, Profit, and crypto tokens.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  /// Factory for Level Badge (L1, L2, etc.)
  factory StatusBadge.level(String level, {bool isSelected = false}) {
    return StatusBadge(
      label: level,
      backgroundColor: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
      textColor: isSelected ? AppColors.brandPrimary : Colors.white,
      borderColor: Colors.transparent,
      fontSize: 13,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    );
  }

  /// Factory for Warning Badge (like PhonePe UPI abnormal warning)
  factory StatusBadge.warning(String text) {
    return StatusBadge(
      label: text,
      icon: Icons.warning_amber_rounded,
      backgroundColor: AppColors.statusWarningBg,
      textColor: AppColors.statusWarning,
      borderColor: AppColors.statusWarning.withValues(alpha: 0.3),
    );
  }

  /// Factory for Bonus Badge (+2.0 green bonus)
  factory StatusBadge.bonus(String text) {
    return StatusBadge(
      label: text,
      backgroundColor: AppColors.profitGreenBg,
      textColor: AppColors.profitGreen,
      borderColor: AppColors.profitGreen.withValues(alpha: 0.3),
      fontSize: 11,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  /// Factory for Crypto Pill (USDT / TRX pill)
  factory StatusBadge.crypto(String symbol) {
    return StatusBadge(
      label: symbol,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 12,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.brandPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 3, color: textColor ?? AppColors.brandPrimary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: textColor ?? AppColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

