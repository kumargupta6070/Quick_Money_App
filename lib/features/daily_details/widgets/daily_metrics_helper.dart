import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class DailySectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final Color accentColor;
  final bool isDark;

  const DailySectionTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.badge,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badge.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

class DailyMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final int delayMs;
  final List<Color>? customGradient;
  final bool isHighlight;
  final VoidCallback? onTap;

  const DailyMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    required this.delayMs,
    this.customGradient,
    this.isHighlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient =
        customGradient ??
        (isDark
            ? [
                accentColor.withValues(alpha: 0.28),
                accentColor.withValues(alpha: 0.14),
              ]
            : [
                accentColor.withValues(alpha: 0.16),
                accentColor.withValues(alpha: 0.08),
                Colors.white,
              ]);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (onTap != null) onTap!();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.50 : 0.40),
                width: isHighlight ? 1.5 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(
                    alpha: isDark ? 0.25 : 0.14,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, size: 13, color: accentColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isHighlight
                          ? accentColor
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 380.ms)
        .slideY(
          begin: 0.12,
          end: 0,
          delay: delayMs.ms,
          curve: Curves.easeOutBack,
        )
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          delay: delayMs.ms,
          duration: 380.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class DailyCryptoGatewayPill extends StatelessWidget {
  final String badge;
  final Color badgeColor;
  final String text;
  final String status;
  final bool isDark;
  final int delayMs;
  final List<Color> pillGradient;

  const DailyCryptoGatewayPill({
    super.key,
    required this.badge,
    required this.badgeColor,
    required this.text,
    required this.status,
    required this.isDark,
    required this.delayMs,
    required this.pillGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: pillGradient,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: badgeColor.withValues(alpha: isDark ? 0.45 : 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: badgeColor.withValues(alpha: isDark ? 0.20 : 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      badgeColor,
                      badgeColor.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 380.ms)
        .slideY(
          begin: 0.12,
          end: 0,
          delay: delayMs.ms,
          curve: Curves.easeOutBack,
        )
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          delay: delayMs.ms,
          duration: 380.ms,
          curve: Curves.easeOutBack,
        );
  }
}
