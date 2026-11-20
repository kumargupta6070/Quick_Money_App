import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Interactive Category Filter Pills
class FaqCategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;
  final bool isDark;

  const FaqCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'All',
        'icon': LucideIcons.layers,
        'color': const Color(0xFF2563EB),
      },
      {
        'name': 'Orders',
        'icon': LucideIcons.trendingUp,
        'color': const Color(0xFFF59E0B),
      },
      {
        'name': 'Payouts',
        'icon': LucideIcons.zap,
        'color': const Color(0xFF10B981),
      },
      {
        'name': 'Team',
        'icon': LucideIcons.users,
        'color': const Color(0xFFEF4444),
      },
      {
        'name': 'Security',
        'icon': LucideIcons.shieldCheck,
        'color': const Color(0xFF06B6D4),
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat['name'];
          final color = cat['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSelectCategory(cat['name'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [color, color.withValues(alpha: 0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark ? const Color(0xFF0F1A30) : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 13,
                      color: isSelected ? Colors.white : color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['name'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
