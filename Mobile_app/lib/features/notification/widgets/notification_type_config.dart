import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quick_money/features/notification/models/notification_model.dart';

class NotificationTypeConfig {
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color borderColor;
  final List<Color> gradientColors;
  final List<Color> cardGradient;
  final List<Color> modalGradient;

  const NotificationTypeConfig({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.borderColor,
    required this.gradientColors,
    required this.cardGradient,
    required this.modalGradient,
  });

  factory NotificationTypeConfig.fromType(NotificationType type, bool isDark) {
    switch (type) {
      case NotificationType.order:
        return NotificationTypeConfig(
          label: 'Order Return',
          icon: LucideIcons.circleDollarSign,
          accentColor: const Color(0xFF10B981),
          borderColor: isDark
              ? const Color(0xFF10B981).withValues(alpha: 0.45)
              : const Color(0xFF10B981).withValues(alpha: 0.40),
          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
          cardGradient: isDark
              ? const [Color(0xFF063E30), Color(0xFF02261E)]
              : const [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFFECFDF5)],
          modalGradient: isDark
              ? const [Color(0xFF0A3D2F), Color(0xFF042119)]
              : const [Color(0xFFE6FFFA), Color(0xFFD1FAE5), Color(0xFFF0FDF4)],
        );
      case NotificationType.rebate:
        return NotificationTypeConfig(
          label: 'Team Rebate',
          icon: LucideIcons.users,
          accentColor: const Color(0xFFEF4444),
          borderColor: isDark
              ? const Color(0xFFF43F5E).withValues(alpha: 0.45)
              : const Color(0xFFF43F5E).withValues(alpha: 0.38),
          gradientColors: const [Color(0xFFEF4444), Color(0xFFF43F5E)],
          cardGradient: isDark
              ? const [Color(0xFF4C0A1A), Color(0xFF28030D)]
              : const [Color(0xFFFFF1F2), Color(0xFFFFE4E6), Color(0xFFFEF2F2)],
          modalGradient: isDark
              ? const [Color(0xFF450A19), Color(0xFF23030B)]
              : const [Color(0xFFFFF1F2), Color(0xFFFFE4E6), Color(0xFFFFF7ED)],
        );
      case NotificationType.reward:
        return NotificationTypeConfig(
          label: 'Special Bonus',
          icon: LucideIcons.gift,
          accentColor: const Color(0xFFF59E0B),
          borderColor: isDark
              ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
              : const Color(0xFFF59E0B).withValues(alpha: 0.40),
          gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
          cardGradient: isDark
              ? const [Color(0xFF451E06), Color(0xFF261003)]
              : const [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFFF7ED)],
          modalGradient: isDark
              ? const [Color(0xFF401C06), Color(0xFF200D02)]
              : const [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFFF1F2)],
        );
      case NotificationType.security:
        return NotificationTypeConfig(
          label: 'Security Alert',
          icon: LucideIcons.shieldCheck,
          accentColor: const Color(0xFF06B6D4),
          borderColor: isDark
              ? const Color(0xFF06B6D4).withValues(alpha: 0.45)
              : const Color(0xFF06B6D4).withValues(alpha: 0.38),
          gradientColors: const [Color(0xFF06B6D4), Color(0xFF0D9488)],
          cardGradient: isDark
              ? const [Color(0xFF083344), Color(0xFF031E28)]
              : const [Color(0xFFECFEFF), Color(0xFFCFFAFE), Color(0xFFF0FDFA)],
          modalGradient: isDark
              ? const [Color(0xFF073040), Color(0xFF031A24)]
              : const [Color(0xFFECFEFF), Color(0xFFE0F2FE), Color(0xFFF0FDF4)],
        );
      case NotificationType.system:
        return NotificationTypeConfig(
          label: 'Platform Update',
          icon: LucideIcons.bell,
          accentColor: const Color(0xFF8B5CF6),
          borderColor: isDark
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.45)
              : const Color(0xFF8B5CF6).withValues(alpha: 0.38),
          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          cardGradient: isDark
              ? const [Color(0xFF2A1058), Color(0xFF160731)]
              : const [Color(0xFFFAF5FF), Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
          modalGradient: isDark
              ? const [Color(0xFF250E4E), Color(0xFF13062B)]
              : const [Color(0xFFFAF5FF), Color(0xFFEDE9FE), Color(0xFFEFF6FF)],
        );
    }
  }
}
