import 'package:flutter/material.dart';
import '../../core/animations/app_animations.dart';

/// Reusable glowing gradient progress bar with live status text and percentage.
class GlowingProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String statusText;
  final Gradient gradient;
  final Color trackColor;
  final double height;
  final bool showPercent;

  const GlowingProgressBar({
    super.key,
    required this.progress,
    required this.statusText,
    this.gradient = AppGradients.progressGradient,
    this.trackColor = const Color(0x1AFFFFFF),
    this.height = 6.0,
    this.showPercent = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percent = (clampedProgress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing Progress Bar Track
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * clampedProgress,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 14),

        // Status Text & Tabular Percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showPercent) ...[
              const SizedBox(width: 8),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Color(0xFFF1F5F9),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

