import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StaggeredAnimation extends StatelessWidget {
  final Widget child;
  final int index;
  final int baseDelayMs;
  final Duration duration;

  const StaggeredAnimation({
    super.key,
    required this.child,
    required this.index,
    this.baseDelayMs = 60,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fade(delay: (index * baseDelayMs).ms, duration: duration)
        .slideY(
          begin: 0.1,
          end: 0,
          delay: (index * baseDelayMs).ms,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}

