import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

/// Animated Ambient Background providing dynamic, glowing orbs blurred smoothly
/// across screens, matching the ICU Mobile App visual depth architecture.
class AnimatedAmbientBackground extends StatelessWidget {
  final Widget child;
  final bool? isDark;

  const AnimatedAmbientBackground({
    super.key,
    required this.child,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final themeIsDark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return Stack(
      children: [
        // 1. Base Gradient Canvas
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: themeIsDark
                  ? const [
                      Color(0xFF070B18),
                      Color(0xFF0F1A34),
                      Color(0xFF090D1E),
                    ]
                  : const [
                      Color(0xFFF1F5F9),
                      Color(0xFFE8EEF8),
                      Color(0xFFF8FAFC),
                    ],
            ),
          ),
        ),

        // 2. Animated Ambient Glowing Orb 1 (Royal Blue / Navy glow)
        Positioned(
          top: -120,
          left: -70,
          child: _buildOrb(
            color: AppColors.brandPrimary.withValues(
              alpha: themeIsDark ? 0.35 : 0.16,
            ),
            size: 340,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .move(
                duration: 10.seconds,
                begin: const Offset(0, 0),
                end: const Offset(60, 90),
              )
              .scale(
                duration: 8.seconds,
                begin: const Offset(1, 1),
                end: const Offset(1.25, 1.25),
              ),
        ),

        // 3. Animated Ambient Glowing Orb 2 (Electric Cyan glow)
        Positioned(
          top: 220,
          right: -90,
          child: _buildOrb(
            color: const Color(0xFF00E5FF).withValues(
              alpha: themeIsDark ? 0.22 : 0.12,
            ),
            size: 270,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .move(
                duration: 12.seconds,
                begin: const Offset(0, 0),
                end: const Offset(-80, -60),
              )
              .scale(
                duration: 9.seconds,
                begin: const Offset(1, 1),
                end: const Offset(1.3, 1.3),
              ),
        ),

        // 4. Animated Ambient Glowing Orb 3 (Gold / Amber glow)
        Positioned(
          bottom: -70,
          left: 40,
          child: _buildOrb(
            color: AppColors.goldAccent.withValues(
              alpha: themeIsDark ? 0.18 : 0.09,
            ),
            size: 240,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .move(
                duration: 14.seconds,
                begin: const Offset(0, 0),
                end: const Offset(90, -70),
              )
              .scale(
                duration: 7.seconds,
                begin: const Offset(1, 1),
                end: const Offset(1.35, 1.35),
              ),
        ),

        // 5. Gaussian Blur Backdrop Filter for silky soft diffusion
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
            child: const SizedBox.expand(),
          ),
        ),

        // 6. Child Content
        child,
      ],
    );
  }

  Widget _buildOrb({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

