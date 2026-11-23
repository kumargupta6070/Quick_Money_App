import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Active sweeping gradient arc spinner with a glowing head particle.
class FinTechSpinnerPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color accentColor;
  final double strokeWidth;

  FinTechSpinnerPainter({
    required this.progress,
    required this.primaryColor,
    required this.accentColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Subtle background track
    final trackPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Active 250° sweeping gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = progress * 2 * math.pi;
    const sweepAngle = 1.38 * math.pi;

    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          primaryColor.withValues(alpha: 0.0),
          accentColor,
          primaryColor,
          Colors.white,
        ],
        stops: const [0.0, 0.45, 0.85, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);

    // 3. Glowing leading white/cyan pearl head
    final headAngle = startAngle + sweepAngle;
    final headX = center.dx + radius * math.cos(headAngle);
    final headY = center.dy + radius * math.sin(headAngle);

    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(headX, headY), strokeWidth * 1.3, glowPaint);

    final headPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(headX, headY), strokeWidth * 0.85, headPaint);
  }

  @override
  bool shouldRepaint(covariant FinTechSpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Slower counter-rotating golden inner arc spinner.
class InnerGoldSpinnerPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  InnerGoldSpinnerPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -progress * 2 * math.pi;
    const sweepAngle = 1.05 * math.pi;

    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.0),
          const Color(0xFFFDE68A),
          const Color(0xFFF59E0B),
          Colors.white,
        ],
        stops: const [0.0, 0.4, 0.85, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant InnerGoldSpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Bouncing and pulsing active loading dots row.
class CustomLoadingDots extends StatelessWidget {
  const CustomLoadingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF00E5FF),
            boxShadow: [BoxShadow(color: Color(0xFF00E5FF), blurRadius: 5, spreadRadius: 1)],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.3, 1.3), delay: Duration(milliseconds: index * 180), duration: const Duration(milliseconds: 400))
            .fade(begin: 0.3, end: 1.0, delay: Duration(milliseconds: index * 180), duration: const Duration(milliseconds: 400));
      }),
    );
  }
}
