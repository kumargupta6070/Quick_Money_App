import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/models/order_model.dart';
import 'admin_package_dialog.dart';

class AdminOrderPackageCard extends ConsumerWidget {
  final OrderModel package;
  final bool isDark;

  const AdminOrderPackageCard({
    super.key,
    required this.package,
    required this.isDark,
  });

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref) async {
    final isActive = package.status == OrderStatus.active;
    final newStatus = isActive ? 'paused' : 'active';

    CustomLoader.show(context, message: 'Updating package status...');
    final ok = await ref.read(adminProvider.notifier).updatePackage(
          id: package.id,
          status: newStatus,
        );

    if (context.mounted) {
      CustomLoader.hide(context);
      if (ok) {
        HapticFeedback.lightImpact();
        CustomSnackBar.showTopSuccess(
          context: context,
          message: 'Package status set to $newStatus',
          icon: LucideIcons.checkCheck,
        );
      } else {
        CustomSnackBar.showTopError(
          context: context,
          message: 'Failed to update package status.',
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        content: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF1E1B2E), Color(0xFF161324)]
                  : const [Colors.white, Color(0xFFFFF5F5)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.4), blurRadius: 10)],
                    ),
                    child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Delete Package?',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 16.5, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Are you sure you want to delete package ${package.level} (${CurrencyFormatter.format(package.orderAmount)})? Traders will no longer see it in the market.',
                style: GoogleFonts.inter(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        CustomLoader.show(context, message: 'Deleting package...');
                        final ok = await ref.read(adminProvider.notifier).deletePackage(package.id);
                        if (context.mounted) {
                          CustomLoader.hide(context);
                          if (ok) {
                            CustomSnackBar.showTopSuccess(context: context, message: 'Package deleted successfully.', icon: LucideIcons.trash2);
                          } else {
                            CustomSnackBar.showTopError(context: context, message: 'Failed to delete package.');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(begin: const Offset(0.9, 0.9), duration: 250.ms, curve: Curves.easeOutBack).fade(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = package.status == OrderStatus.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2E1065), Color(0xFF1E293B)]
              : const [Colors.white, Color(0xFFFAF5FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.45 : 0.35)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Level + Status Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${package.level} PACKAGE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Qty: ${package.orderQuantity}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    isActive ? 'Active' : 'Paused',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isActive ? const Color(0xFF10B981) : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch.adaptive(
                    value: isActive,
                    activeThumbColor: const Color(0xFF10B981),
                    onChanged: (_) => _toggleStatus(context, ref),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Main Price & Reward Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(package.orderAmount),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+₹${package.reward.toStringAsFixed(2)} RP',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${package.bonus.toStringAsFixed(1)}%',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons: Edit Package & Delete with distinct backgrounds
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.45 : 0.35),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AdminPackageDialog(
                          package: package,
                          isDark: isDark,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.pencil, size: 14, color: Color(0xFF0284C7)),
                          const SizedBox(width: 6),
                          Text(
                            'Edit Package',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.45 : 0.35),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _confirmDelete(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                          const SizedBox(width: 5),
                          Text(
                            'Delete',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
