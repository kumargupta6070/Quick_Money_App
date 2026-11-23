import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

/// Quick Money Enterprise Custom SnackBar with rich dark/light mode aesthetics,
/// vibrant status colors, and smooth micro-animations.
/// All trigger alerts, messages, and notifications in the app MUST use this class.
class CustomSnackBar {
  /// Strips technical exception prefixes, error wrapper text, and HTTP status codes
  /// so users only ever see clear, friendly backend or system messages.
  static String sanitizeMessage(String raw) {
    var cleaned = raw.trim();
    // Strip prefixes like "ApiException: ", "DioException: ", "Exception: ", "Error: "
    cleaned = cleaned.replaceAll(
      RegExp(r'^(ApiException|DioException|Exception|Error):\s*', caseSensitive: false),
      '',
    );
    // Strip status code patterns like "(Status: 400)", "[Status: 400]", "(HTTP 400)", "Status: 400"
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*[\(\[]?\s*(Status|HTTP|Code):\s*\d+\s*[\)\]]?', caseSensitive: false),
      '',
    );
    // Strip wrapping quotes
    cleaned = cleaned.replaceAll(RegExp(r'''^["']|["']$'''), '');
    cleaned = cleaned.trim();
    if (cleaned.isEmpty) {
      return 'Something went wrong. Please try again.';
    }
    return cleaned;
  }

  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isInfo = false,
    bool isWarning = false,
    bool? isSuccess,
    IconData? icon,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (!context.mounted) return;

    final effectiveIsError = isSuccess == true ? false : isError;
    final sanitizedMessage = sanitizeMessage(message);

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
        content:
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.5),
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
                          sanitizedMessage,
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
                .slideY(
                  begin: 0.5,
                  end: 0,
                  curve: Curves.easeOutCubic,
                  duration: 400.ms,
                )
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

  /// Convenience shortcut for displaying error notifications (6 seconds duration for clear readability)
  static void showError({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 6),
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
    Duration duration = const Duration(seconds: 5),
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
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context: context,
      message: message,
      isWarning: true,
      icon: icon,
      duration: duration,
    );
  }

  static OverlayEntry? _activeToast;

  /// High-priority top toast rendered via rootOverlay so it floats above all
  /// modal bottom sheets, dialogs, and navigation routes.
  static void showTopToast({
    required BuildContext context,
    required String message,
    IconData? icon,
    bool isError = false,
    bool isWarning = false,
    bool isInfo = false,
    Duration duration = const Duration(seconds: 5),
  }) {
    _activeToast?.remove();
    _activeToast = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final cleanMessage = sanitizeMessage(message);

    // Determine colors and icon based on status
    final List<Color> gradientColors;
    final Color shadowColor;
    final Color borderColor;
    final IconData effectiveIcon;

    if (isError) {
      gradientColors = const [Color(0xFF991B1B), Color(0xFFEF4444)];
      shadowColor = const Color(0xFFEF4444);
      borderColor = const Color(0xFFFCA5A5).withValues(alpha: 0.40);
      effectiveIcon = icon ?? Icons.error_outline_rounded;
    } else if (isWarning) {
      gradientColors = const [Color(0xFFB45309), Color(0xFFF59E0B)];
      shadowColor = const Color(0xFFF59E0B);
      borderColor = const Color(0xFFFDE68A).withValues(alpha: 0.45);
      effectiveIcon = icon ?? Icons.warning_amber_rounded;
    } else if (isInfo) {
      gradientColors = const [Color(0xFF0369A1), Color(0xFF0284C7)];
      shadowColor = const Color(0xFF0284C7);
      borderColor = const Color(0xFFBAE6FD).withValues(alpha: 0.40);
      effectiveIcon = icon ?? Icons.info_outline_rounded;
    } else {
      // Default Success
      gradientColors = const [Color(0xFF065F46), Color(0xFF10B981)];
      shadowColor = const Color(0xFF10B981);
      borderColor = Colors.white.withValues(alpha: 0.35);
      effectiveIcon = icon ?? Icons.check_circle_rounded;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        final topPadding = MediaQuery.of(ctx).padding.top;
        return Positioned(
          top: topPadding + 14,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_activeToast == entry) {
                  entry.remove();
                  _activeToast = null;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        effectiveIcon,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cleanMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 250.ms)
              .slideY(begin: -0.4, end: 0, curve: Curves.easeOutCubic),
            ),
          ),
        );
      },
    );

    _activeToast = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (_activeToast == entry) {
        entry.remove();
        _activeToast = null;
      }
    });
  }

  /// High-priority top warning alert floating above modals, bottom sheets and dialogs
  static void showTopWarning({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 5),
  }) {
    showTopToast(
      context: context,
      message: message,
      isWarning: true,
      icon: icon ?? Icons.warning_amber_rounded,
      duration: duration,
    );
  }

  /// High-priority top error alert (6 seconds display time for complete readability)
  static void showTopError({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 6),
  }) {
    showTopToast(
      context: context,
      message: message,
      isError: true,
      icon: icon ?? Icons.error_outline_rounded,
      duration: duration,
    );
  }

  /// High-priority top success alert floating above modals, bottom sheets and dialogs
  static void showTopSuccess({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    showTopToast(
      context: context,
      message: message,
      icon: icon ?? Icons.check_circle_rounded,
      duration: duration,
    );
  }

  /// High-priority top info alert floating above modals, bottom sheets and dialogs
  static void showTopInfo({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 5),
  }) {
    showTopToast(
      context: context,
      message: message,
      isInfo: true,
      icon: icon ?? Icons.info_outline_rounded,
      duration: duration,
    );
  }
}
