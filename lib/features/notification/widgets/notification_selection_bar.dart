import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationSelectionBar extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onDeleteSelected;
  final VoidCallback onCancel;
  final bool isDark;

  const NotificationSelectionBar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onToggleSelectAll,
    required this.onDeleteSelected,
    required this.onCancel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final allSelected = selectedCount == totalCount && totalCount > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1E1B4B), Color(0xFF2E1065)]
              : const [Color(0xFFEEF2FF), Color(0xFFFAF5FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel selection
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onCancel();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.x,
                size: 16,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Count Text
          Flexible(
            child: Text(
              '$selectedCount Selected',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E1B4B),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Select All / Deselect All
          TextButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onToggleSelectAll();
            },
            icon: Icon(
              allSelected ? LucideIcons.checkCheck : LucideIcons.check,
              size: 13,
              color: const Color(0xFF7C3AED),
            ),
            label: Text(
              allSelected ? 'None' : 'All',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7C3AED),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),

          const SizedBox(width: 6),

          // Delete Action
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onDeleteSelected();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.trash2, size: 13, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Delete',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.1, end: 0);
  }
}
