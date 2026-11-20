import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_money/features/notification/models/notification_model.dart';

class NotificationFilterBar extends StatelessWidget {
  final List<NotificationModel> allItems;
  final int unreadCount;
  final String selectedFilter;
  final Function(String) onFilterSelected;
  final bool isDark;

  const NotificationFilterBar({
    super.key,
    required this.allItems,
    required this.unreadCount,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F1930)
            : const Color(0xFFF1F5F9).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip('All', allItems.length),
            const SizedBox(width: 6),
            _buildFilterChip('Unread', unreadCount, isHighlight: true),
            const SizedBox(width: 6),
            _buildFilterChip('Earnings', null),
            const SizedBox(width: 6),
            _buildFilterChip('System', null),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    int? count, {
    bool isHighlight = false,
  }) {
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onFilterSelected(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
            width: 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569)),
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isHighlight
                          ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                          : const Color(0xFF0284C7).withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : (isHighlight
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF0284C7)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
