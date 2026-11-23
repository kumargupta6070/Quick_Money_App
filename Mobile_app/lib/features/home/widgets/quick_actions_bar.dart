import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 4 High-Frequency Quick Action Shortcuts directly modeled after the ICU Mobile App Quick Actions.
/// Features circular glowing icon containers, responsive themes, and staggered entrance animations.
class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      {
        'label': 'Deposit',
        'icon': LucideIcons.arrowDownToLine,
        'color': const Color(0xFF00E5FF),
        'gradient': const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'onTap': () => context.push('/daily-details'),
      },
      {
        'label': 'Buy RP',
        'icon': LucideIcons.shoppingBag,
        'color': const Color(0xFF3B82F6),
        'gradient': const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'onTap': () => context.go('/buy-rp'),
      },
      {
        'label': 'Sell RP',
        'icon': LucideIcons.refreshCw,
        'color': const Color(0xFF10B981),
        'gradient': const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'onTap': () => context.go('/sell-rp'),
      },
      {
        'label': 'Team 3X',
        'icon': LucideIcons.users,
        'color': const Color(0xFFF59E0B),
        'gradient': const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'onTap': () => context.push('/team'),
      },
    ];

    return Row(
      children: List.generate(actions.length, (index) {
        final item = actions[index];
        final color = item['color'] as Color;
        final gradient = item['gradient'] as Gradient;
        final icon = item['icon'] as IconData;
        final label = item['label'] as String;
        final onTap = item['onTap'] as VoidCallback;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 5,
              right: index == actions.length - 1 ? 0 : 5,
            ),
            child: _buildActionItem(
              context: context,
              icon: icon,
              label: label,
              color: color,
              gradient: gradient,
              onTap: onTap,
              index: index,
              isDark: isDark,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
    required int index,
    required bool isDark,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        color.withValues(alpha: 0.22),
                        color.withValues(alpha: 0.08),
                      ]
                    : [
                        color.withValues(alpha: 0.16),
                        color.withValues(alpha: 0.06),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.38 : 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isDark ? 0.20 : 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradient,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.40),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, size: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 60 * index))
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1, 1),
          duration: 350.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 350.ms);
  }
}
