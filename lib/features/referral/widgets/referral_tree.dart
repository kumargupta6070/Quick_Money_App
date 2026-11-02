import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class ReferralTree extends StatelessWidget {
  const ReferralTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildNode('Level 1: Direct Referrals', '5% Commission', AppColors.brandPrimary, LucideIcons.userCheck),
        const Icon(Icons.arrow_downward_rounded, size: 20, color: Colors.grey),
        _buildNode('Level 2: Secondary Friends', '3% Commission', AppColors.purpleAccent, LucideIcons.users),
        const Icon(Icons.arrow_downward_rounded, size: 20, color: Colors.grey),
        _buildNode('Level 3: Community Circle', '1% Commission', AppColors.profitGreen, LucideIcons.network),
      ],
    );
  }

  Widget _buildNode(String title, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

