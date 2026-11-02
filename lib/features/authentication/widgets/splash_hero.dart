import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/levitating_widget.dart';
import '../../../shared/widgets/rotating_ring_emblem.dart';

/// Hero animated element for Splash and Auth screens with levitation and rotating ring.
class SplashHero extends StatelessWidget {
  final double size;

  const SplashHero({super.key, this.size = 136});

  @override
  Widget build(BuildContext context) {
    return LevitatingWidget(
      distance: 8.0,
      duration: const Duration(milliseconds: 2400),
      child: RotatingRingEmblem(
        size: size,
        ringWidth: 3.5,
        child: Image.asset(
          AssetPaths.appIcon,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.brandPrimary,
            child: const Center(
              child: Text(
                '₹',
                style: TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1.0, 1.0),
          duration: 900.ms,
          curve: Curves.elasticOut,
        )
        .fade(duration: 500.ms);
  }
}

