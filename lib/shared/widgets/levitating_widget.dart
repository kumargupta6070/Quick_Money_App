import 'package:flutter/material.dart';

/// Reusable widget wrapper providing smooth, continuous vertical 3D levitation motion.
class LevitatingWidget extends StatefulWidget {
  final Widget child;
  final double distance;
  final Duration duration;

  const LevitatingWidget({
    super.key,
    required this.child,
    this.distance = 8.0,
    this.duration = const Duration(milliseconds: 2200),
  });

  @override
  State<LevitatingWidget> createState() => _LevitatingWidgetState();
}

class _LevitatingWidgetState extends State<LevitatingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -widget.distance,
      end: widget.distance,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

