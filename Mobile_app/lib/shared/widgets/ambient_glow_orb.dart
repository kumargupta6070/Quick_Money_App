import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable atmospheric ambient glowing radial orb for modern FinTech screens.
/// Features a smooth breathing/pulsing scale animation.
class AmbientGlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double maxOpacity;
  final Duration pulseDuration;
  final double minScale;
  final double maxScale;

  const AmbientGlowOrb({
    super.key,
    required this.size,
    required this.color,
    this.maxOpacity = 0.35,
    this.pulseDuration = const Duration(seconds: 3),
    this.minScale = 0.85,
    this.maxScale = 1.25,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: maxOpacity),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: Offset(minScale, minScale),
          end: Offset(maxScale, maxScale),
          duration: pulseDuration,
          curve: Curves.easeInOutSine,
        );
  }
}

