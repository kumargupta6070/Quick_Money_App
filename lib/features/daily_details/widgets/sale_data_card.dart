import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SaleDataCard extends StatelessWidget {
  final int sellNumber;
  final double sellAmount;

  const SaleDataCard({
    super.key,
    required this.sellNumber,
    required this.sellAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
        boxShadow: AppSpacing.cardShadow(context),
      ),
      child: Row(
        children: [
          _buildCell(context, 'Number', '$sellNumber'),
          _buildDivider(context),
          _buildCell(context, 'Amount', '$sellAmount', isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, String label, String val, {bool isHighlight = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isHighlight ? AppColors.brandPrimary : (isDark ? AppColors.darkText : AppColors.lightText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 36,
      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
    );
  }
}

