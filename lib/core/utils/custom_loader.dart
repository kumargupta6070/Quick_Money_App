import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Next-Level, Ultra-Designable, Colorful & Active Animated Custom Loader for Quick Money.
/// Features dual counter-rotating gradient sweep arcs, leading glowing particle heads,
/// breathing central 3D Rupee coin, traveling loading dots, and frosted glass dialogs.
class CustomLoader extends StatefulWidget {
  final double size;
  final String? message;
  final bool showGlow;
  final bool showSubtext;

  const CustomLoader({
    super.key,
    this.size = 68.0,
    this.message,
    this.showGlow = true,
    this.showSubtext = false,
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();

  /// Small glowing loader for buttons and inline widgets
  static Widget inline({double size = 20, Color color = const Color(0xFF00E5FF)}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        strokeCap: StrokeCap.round,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  /// Centered loader for screens and tabs
  static Widget centered({String message = 'Loading...'}) {
    return Center(
      child: CustomLoader(
        size: 72,
        message: message,
        showSubtext: true,
      ),
    );
  }

  /// Displays an ultra-modern modal loading overlay with backdrop blur & neon glow
  static void show(BuildContext context, {String message = 'Processing...'}) =>
      showOverlay(context, message: message);

  /// Dismisses active overlay loader safely
  static void hide(BuildContext context) => dismiss(context);

  /// Displays the full modal loading overlay
  static void showOverlay(BuildContext context, {String message = 'Processing...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 36),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF090F24).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                      blurRadius: 36,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                      blurRadius: 24,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // High-Energy Active Dual-Arc Spinner
                    const CustomLoader(
                      size: 74,
                      showGlow: true,
                    ),

                    const SizedBox(height: 22),

                    // Main Loading Message
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Active Bouncing Loading Dots
                    const _LoadingDots(),

                    const SizedBox(height: 12),

                    // Animated Security Beacon Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF10B981),
                                  blurRadius: 6,
                                  spreadRadius: 1.5,
                                ),
                              ],
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(begin: 0.3, end: 1.0, duration: 600.ms),
                          const SizedBox(width: 6),
                          const Text(
                            'SECURE AES-256 SESSION',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.75, 0.75),
                    end: const Offset(1.0, 1.0),
                    duration: 350.ms,
                    curve: Curves.elasticOut,
                  )
                  .fade(duration: 250.ms),
            ),
          ),
        );
      },
    );
  }

  /// Dismisses active overlay loader safely
  static void dismiss(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

class _CustomLoaderState extends State<CustomLoader> with TickerProviderStateMixin {
  late final AnimationController _outerController;
  late final AnimationController _innerController;

  @override
  void initState() {
    super.initState();

    // Fast clockwise outer spinner
    _outerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    // Slower counter-clockwise inner spinner
    _innerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
  }

  @override
  void dispose() {
    _outerController.dispose();
    _innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // ── Layer 1: Ambient Glowing Halo ──
            if (widget.showGlow)
              Container(
                width: size + 16,
                height: size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00E5FF).withValues(alpha: 0.35),
                      const Color(0xFF2563EB).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.15, 1.15), duration: 1200.ms),

            // ── Layer 2: Fast Clockwise Cyan/Blue Outer Arc with Glowing Head ──
            AnimatedBuilder(
              animation: _outerController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(size, size),
                  painter: _FinTechSpinnerPainter(
                    progress: _outerController.value,
                    primaryColor: const Color(0xFF00E5FF),
                    accentColor: const Color(0xFF2563EB),
                    strokeWidth: 4.2,
                  ),
                );
              },
            ),

            // ── Layer 3: Counter-Clockwise Golden Inner Arc ──
            AnimatedBuilder(
              animation: _innerController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(size * 0.72, size * 0.72),
                  painter: _InnerGoldSpinnerPainter(
                    progress: _innerController.value,
                    strokeWidth: 2.8,
                  ),
                );
              },
            ),

            // ── Layer 4: Center Floating Glass Coin with Glowing Rupee Symbol ──
            Container(
              width: size * 0.44,
              height: size * 0.44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF00E5FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '₹',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.08, 1.08), duration: 800.ms),
          ],
        ),

        // Optional Message for Centered Loader
        if (widget.message != null && widget.message!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],

        // Optional Subtext for Centered Loader
        if (widget.showSubtext) ...[
          const SizedBox(height: 6),
          const Text(
            'Quick Money • Secure Processing',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }
}

/// Active sweeping gradient arc spinner with a glowing head particle.
class _FinTechSpinnerPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color accentColor;
  final double strokeWidth;

  _FinTechSpinnerPainter({
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
  bool shouldRepaint(covariant _FinTechSpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Slower counter-rotating golden inner arc spinner.
class _InnerGoldSpinnerPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _InnerGoldSpinnerPainter({
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
  bool shouldRepaint(covariant _InnerGoldSpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Bouncing and pulsing active loading dots row.
class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

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
            boxShadow: [
              BoxShadow(
                color: Color(0xFF00E5FF),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.3, 1.3),
              delay: Duration(milliseconds: index * 180),
              duration: const Duration(milliseconds: 400),
            )
            .fade(
              begin: 0.3,
              end: 1.0,
              delay: Duration(milliseconds: index * 180),
              duration: const Duration(milliseconds: 400),
            );
      }),
    );
  }
}
