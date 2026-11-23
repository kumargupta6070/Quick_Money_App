import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../shared/widgets/gradient_text.dart';
import '../../../shared/widgets/levitating_widget.dart';
import '../../../shared/widgets/rotating_ring_emblem.dart';

/// Reusable top header for Auth screens with floating 3D emblem, glowing gradient title, and subtitle.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double iconSize;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.iconSize = 82,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Levitating Floating 3D Emblem with Rotating Gradient Ring
        LevitatingWidget(
          distance: 6.0,
          duration: const Duration(milliseconds: 2200),
          child: RotatingRingEmblem(
            size: iconSize,
            ringWidth: 3.0,
            child: Image.asset(
              AssetPaths.appIcon,
              fit: BoxFit.cover,
            ),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.elasticOut,
            )
            .fade(duration: 400.ms),

        const SizedBox(height: 18),

        // Glowing Multi-stop Gradient Title
        GradientText(
          title,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFE0F2FE),
              Color(0xFFFDE68A),
              Colors.white,
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          ),
        )
            .animate()
            .fade(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms),

        const SizedBox(height: 6),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
              height: 1.45,
            ),
          ),
        )
            .animate()
            .fade(delay: 350.ms, duration: 400.ms),
      ],
    );
  }
}
