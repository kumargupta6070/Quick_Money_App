import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_spacing.dart';

/// Reusable Animated Card matching the ICU Mobile App architecture.
/// Provides consistent borders, elevations, subtle tinted surfaces,
/// interactive press scale, and staggered entrance animation using [index].
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final int index;
  final int animationDelayMs;
  final bool animate;

  const AnimatedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.borderRadius = AppSpacing.radiusLg,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.index = 0,
    this.animationDelayMs = 0,
    this.animate = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        widget.backgroundColor ??
        (isDark
            ? const Color(0xFF131D38).withValues(alpha: 0.90)
            : Colors.white);
    final cardBorder =
        widget.borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0));

    Widget card = AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: cardBorder, width: 1.2),
          boxShadow: AppSpacing.cardShadow(context),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (pressed) {
              if (widget.onTap != null) {
                setState(() => _isPressed = pressed);
              }
            },
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (!widget.animate) return card;

    final effectiveDelayMs = widget.animationDelayMs > 0
        ? widget.animationDelayMs
        : (widget.index * 70);

    return card
        .animate(delay: Duration(milliseconds: effectiveDelayMs))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
