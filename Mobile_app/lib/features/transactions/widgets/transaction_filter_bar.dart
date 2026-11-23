import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Filter Tabs (All, Payout Returns, Deposits)
class TransactionFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final bool isDark;

  const TransactionFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.isDark,
  });

  Widget _buildFilterTabItem(String key, String label) {
    final isSelected = selectedFilter == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onFilterChanged(key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xFF0F172A))
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A1228)
            : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildFilterTabItem('all', 'All Records')),
          Expanded(child: _buildFilterTabItem('payout', 'PhonePe Returns')),
          Expanded(child: _buildFilterTabItem('deposit', 'Deposits')),
        ],
      ),
    );
  }
}
