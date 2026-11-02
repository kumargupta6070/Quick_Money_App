import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/animations/app_animations.dart';

/// Reusable 3D Rotating Gradient Ring Emblem.
/// Perfect for App Logo, Level Badges, Profile Avatars, and Hero Coins.
class RotatingRingEmblem extends StatefulWidget {
  final Widget child;
  final double size;
  final double ringWidth;
  final Duration rotationDuration;
  final Gradient ringGradient;
  final List<BoxShadow>? shadows;
  final Color innerBackground;

  const RotatingRingEmblem({
    super.key,
    required this.child,
    this.size = 136,
    this.ringWidth = 3.5,
    this.rotationDuration = const Duration(seconds: 8),
    this.ringGradient = AppGradients.goldSweep,
    this.shadows,
    this.innerBackground = const Color(0xFF090E20),
  });

  @override
  State<RotatingRingEmblem> createState() => _RotatingRingEmblemState();
}

class _RotatingRingEmblemState extends State<RotatingRingEmblem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultShadows = widget.shadows ?? AppShadows.dualGlow;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing Soft Ambient Glow
        Container(
          width: widget.size + 12,
          height: widget.size + 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: defaultShadows,
          ),
        ),

        // Animated Rotating Gradient Ring
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.ringGradient,
                ),
                child: Padding(
                  padding: EdgeInsets.all(widget.ringWidth),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.innerBackground,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Inner Child (Emblem / Avatar / Coin) with Glassmorphic Border
        Container(
          width: widget.size - (widget.ringWidth * 2) - 14,
          height: widget.size - (widget.ringWidth * 2) - 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(child: widget.child),
        ),
      ],
    );
  }
}

