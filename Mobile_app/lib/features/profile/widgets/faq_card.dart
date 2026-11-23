import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Individual FAQ Card with distinct Category Color Gradients & Glow
class FaqCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final int index;

  const FaqCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final lightBg = item['lightBg'] as List<Color>;
    final darkBg = item['darkBg'] as List<Color>;
    final accentColor = item['accentColor'] as Color;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? darkBg : lightBg,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.28),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.14 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              item['icon'] as IconData,
              size: 18,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item['q'] as String,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.8,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['tag'] as String,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  item['a'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (40 + index * 30).ms, duration: 320.ms)
        .slideY(
          begin: 0.05,
          end: 0,
          delay: (40 + index * 30).ms,
          curve: Curves.easeOutCubic,
        );
  }
}
