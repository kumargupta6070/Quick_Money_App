import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Quick Money Enterprise Custom SnackBar with rich dark/light mode aesthetics,
/// vibrant status colors, and smooth micro-animations.
/// All trigger alerts, messages, and notifications in the app MUST use this class.
class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isInfo = false,
    bool isWarning = false,
    bool? isSuccess,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    final effectiveIsError = isSuccess == true ? false : isError;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Determine color schemes
    final Color bgColor;
    final Color borderColor;
    final Color iconBgColor;
    final Color textColor;
    final Color shadowColor;
    final IconData effectiveIcon;

    if (effectiveIsError) {
      bgColor = isDark ? const Color(0xFF3B1212) : const Color(0xFFFEF2F2);
      borderColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5);
      iconBgColor = isDark ? const Color(0xFF991B1B) : AppColors.statusCritical;
      textColor = isDark ? const Color(0xFFFECACA) : const Color(0xFF991B1B);
      shadowColor = Colors.red;
      effectiveIcon = icon ?? Icons.error_outline_rounded;
    } else if (isWarning) {
      bgColor = isDark ? const Color(0xFF332308) : const Color(0xFFFFFBEB);
      borderColor = isDark ? const Color(0xFF784807) : const Color(0xFFFDE68A);
      iconBgColor = isDark ? const Color(0xFFB45309) : AppColors.statusWarning;
      textColor = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
      shadowColor = Colors.amber;
      effectiveIcon = icon ?? Icons.warning_amber_rounded;
    } else if (isInfo) {
      bgColor = isDark ? const Color(0xFF0C243C) : const Color(0xFFF0F9FF);
      borderColor = isDark ? const Color(0xFF0E4C7A) : const Color(0xFFBAE6FD);
      iconBgColor = isDark ? const Color(0xFF0369A1) : AppColors.statusInfo;
      textColor = isDark ? const Color(0xFFBAE6FD) : const Color(0xFF075985);
      shadowColor = AppColors.statusInfo;
      effectiveIcon = icon ?? Icons.info_outline_rounded;
    } else {
      // Success
      bgColor = isDark ? const Color(0xFF0A2B19) : const Color(0xFFF0FDF4);
      borderColor = isDark ? const Color(0xFF166534) : const Color(0xFF86EFAC);
      iconBgColor = isDark ? const Color(0xFF15803D) : AppColors.profitGreen;
      textColor = isDark ? const Color(0xFFBBF7D0) : const Color(0xFF14532D);
      shadowColor = Colors.green;
      effectiveIcon = icon ?? Icons.check_circle_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  effectiveIcon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic, duration: 400.ms)
            .fade(duration: 400.ms),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        padding: EdgeInsets.zero,
        duration: duration,
      ),
    );
  }

  /// Convenience shortcut for displaying error notifications
  static void showError({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      isError: true,
      icon: icon,
      duration: duration,
    );
  }

  /// Convenience shortcut for displaying success notifications
  static void showSuccess({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      isError: false,
      isSuccess: true,
      icon: icon,
      duration: duration,
    );
  }

  /// Convenience shortcut for displaying info notifications
  static void showInfo({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      isInfo: true,
      icon: icon,
      duration: duration,
    );
  }

  /// Convenience shortcut for displaying warning notifications
  static void showWarning({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      isWarning: true,
      icon: icon,
      duration: duration,
    );
  }
}

