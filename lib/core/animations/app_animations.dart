import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centralized animation durations, curves, shadows, and static animation builders
/// aligned with the ICU Mobile App architecture for consistent motion design.
class AppAnimations {
  // Standard Durations
  static const Duration defaultDuration = Duration(milliseconds: 350);
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 700);
  static const Duration verySlow = Duration(milliseconds: 1000);
  static const Duration splash = Duration(milliseconds: 4200);

  // Curves
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve enterCurve = Curves.decelerate;
  static const Curve exitCurve = Curves.fastOutSlowIn;
  static const Curve floatCurve = Curves.easeInOutSine;

  // ICU-Style Static Animation Builders
  static Widget fadeIn(Widget child, {Duration? delay, Duration? duration}) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? defaultDuration, curve: defaultCurve);
  }

  static Widget slideUp(
    Widget child, {
    Duration? delay,
    Duration? duration,
    double begin = 0.1,
  }) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? defaultDuration, curve: defaultCurve)
        .slideY(
          begin: begin,
          end: 0,
          duration: duration ?? defaultDuration,
          curve: defaultCurve,
        );
  }

  static Widget slideLeft(
    Widget child, {
    Duration? delay,
    Duration? duration,
    double begin = 0.15,
  }) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? defaultDuration, curve: defaultCurve)
        .slideX(
          begin: begin,
          end: 0,
          duration: duration ?? defaultDuration,
          curve: defaultCurve,
        );
  }

  static Widget slideRight(
    Widget child, {
    Duration? delay,
    Duration? duration,
    double begin = -0.15,
  }) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? defaultDuration, curve: defaultCurve)
        .slideX(
          begin: begin,
          end: 0,
          duration: duration ?? defaultDuration,
          curve: defaultCurve,
        );
  }

  static Widget scaleIn(Widget child, {Duration? delay, Duration? duration}) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration ?? defaultDuration, curve: defaultCurve)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: duration ?? defaultDuration,
          curve: Curves.easeOutBack,
        );
  }

  static Widget pulse(Widget child, {Color? tintColor}) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 800.ms,
          curve: Curves.easeInOut,
        );
  }

  static Widget heartbeat(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.04, 1.04),
          duration: 150.ms,
          curve: Curves.easeOut,
        )
        .then(delay: 50.ms)
        .scale(
          begin: const Offset(1.04, 1.04),
          end: const Offset(1, 1),
          duration: 150.ms,
          curve: Curves.easeIn,
        )
        .then(delay: 150.ms)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.04, 1.04),
          duration: 150.ms,
          curve: Curves.easeOut,
        )
        .then(delay: 50.ms)
        .scale(
          begin: const Offset(1.04, 1.04),
          end: const Offset(1, 1),
          duration: 150.ms,
          curve: Curves.easeIn,
        )
        .then(delay: 800.ms);
  }
}

/// Common FinTech Glow Shadows reusable across cards, badges, and emblems.
class AppShadows {
  static List<BoxShadow> neonBlue({double opacity = 0.5, double blur = 30}) => [
    BoxShadow(
      color: const Color(0xFF2563EB).withValues(alpha: opacity),
      blurRadius: blur,
      spreadRadius: blur * 0.15,
    ),
  ];

  static List<BoxShadow> goldGlow({double opacity = 0.45, double blur = 25}) =>
      [
        BoxShadow(
          color: const Color(0xFFF59E0B).withValues(alpha: opacity),
          blurRadius: blur,
          spreadRadius: blur * 0.1,
        ),
      ];

  static List<BoxShadow> emeraldGlow({
    double opacity = 0.45,
    double blur = 25,
  }) => [
    BoxShadow(
      color: const Color(0xFF10B981).withValues(alpha: opacity),
      blurRadius: blur,
      spreadRadius: blur * 0.1,
    ),
  ];

  static List<BoxShadow> dualGlow = [
    BoxShadow(
      color: const Color(0xFF2563EB).withValues(alpha: 0.45),
      blurRadius: 36,
      spreadRadius: 6,
    ),
    BoxShadow(
      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
      blurRadius: 28,
      spreadRadius: 2,
    ),
  ];
}

/// Standard reusable luxury FinTech gradients.
class AppGradients {
  static const SweepGradient goldSweep = SweepGradient(
    colors: [
      Color(0xFFF59E0B), // Gold
      Color(0xFF00E5FF), // Cyan
      Color(0xFF2563EB), // Royal Blue
      Color(0xFF10B981), // Emerald
      Color(0xFFF59E0B), // Loop Gold
    ],
  );

  static const LinearGradient electricCyan = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient royalGold = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFDE68A), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGrowth = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [
      Color(0xFF2563EB), // Royal Blue
      Color(0xFF00E5FF), // Cyan
      Color(0xFFF59E0B), // Gold
      Color(0xFF10B981), // Emerald
    ],
  );
}
