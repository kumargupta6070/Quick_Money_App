import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/widgets/animated_ambient_background.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _selectedLevel = 'ALL';
  final List<String> _levels = ['ALL', 'L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).fetchPackages(level: _selectedLevel);
    });
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await ref.read(adminProvider.notifier).fetchPackages(level: _selectedLevel);
  }

  void _filterLevel(String lvl) {
    HapticFeedback.selectionClick();
    setState(() => _selectedLevel = lvl);
    ref.read(adminProvider.notifier).fetchPackages(level: lvl);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminState = ref.watch(adminProvider);
    final packages = adminState.packages;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RP Order Book Manager',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            onPressed: _onRefresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPackageDialog(context, null),
        backgroundColor: const Color(0xFF0284C7),
        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
        label: Text(
          'New RP Package',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      body: AnimatedAmbientBackground(
        child: Column(
          children: [
            // Level Selector Filter Row
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _levels.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final lvl = _levels[i];
                  final isSelected = lvl == _selectedLevel;
                  return ChoiceChip(
                    label: Text(lvl),
                    selected: isSelected,
                    onSelected: (_) => _filterLevel(lvl),
                    selectedColor: const Color(0xFF0284C7),
                    labelStyle: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
                    ),
                  );
                },
              ),
            ),

            // Packages List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFF0284C7),
                child: packages.isEmpty && !adminState.isLoading
                    ? Center(
                        child: Text(
                          'No packages found for tier $_selectedLevel',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: packages.length,
                        itemBuilder: (context, index) {
                          final pkg = packages[index];
                          return _buildPackageCard(context, pkg, isDark)
                              .animate(delay: Duration(milliseconds: 30 * index))
                              .fadeIn(duration: 250.ms)
                              .slideY(begin: 0.05, end: 0);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, OrderModel pkg, bool isDark) {
    final isActive = pkg.status.name.toLowerCase() == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFF0284C7).withValues(alpha: isDark ? 0.35 : 0.25)
              : const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Level Badge + Available Quantity + Status Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pkg.level,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${pkg.orderQuantity} orders available',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : 'PAUSED',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Switch.adaptive(
                    value: isActive,
                    activeThumbColor: const Color(0xFF10B981),
                    onChanged: (val) async {
                      final newStatus = val ? 'active' : 'paused';
                      final ok = await ref.read(adminProvider.notifier).updatePackage(
                            id: pkg.id,
                            status: newStatus,
                          );
                      if (context.mounted && ok) {
                        CustomSnackBar.showSuccess(
                          context: context,
                          message: 'Package status updated to $newStatus',
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Main Price & Final RP Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(pkg.orderAmount),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Final: ${pkg.finalRp.toStringAsFixed(1)} RP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Chips Breakdown
          Row(
            children: [
              _buildRewardChip('Reward: +₹${pkg.reward.toStringAsFixed(2)}', const Color(0xFFD97706), isDark),
              const SizedBox(width: 8),
              _buildRewardChip('Bonus: +₹${pkg.bonus.toStringAsFixed(2)}', const Color(0xFF059669), isDark),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons: Edit & Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showPackageDialog(context, pkg),
                icon: const Icon(LucideIcons.pencil, size: 14),
                label: const Text('Edit Details'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDelete(context, pkg),
                icon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                label: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChip(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, OrderModel pkg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete RP Package?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to remove package ${CurrencyFormatter.format(pkg.orderAmount)}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).deletePackage(pkg.id);
              if (context.mounted && ok) {
                CustomSnackBar.showSuccess(context: context, message: 'Package deleted successfully');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  void _showPackageDialog(BuildContext context, OrderModel? pkg) {
    final isEditing = pkg != null;
    final amountCtrl = TextEditingController(text: isEditing ? pkg.orderAmount.toString() : '');
    final qtyCtrl = TextEditingController(text: isEditing ? pkg.orderQuantity.toString() : '50');
    final rewardCtrl = TextEditingController(text: isEditing ? pkg.reward.toString() : '');
    final bonusCtrl = TextEditingController(text: isEditing ? pkg.bonus.toString() : '2.0');
    String level = isEditing ? pkg.level : (_selectedLevel == 'ALL' ? 'L1' : _selectedLevel);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isEditing ? 'Edit RP Package' : 'Create RP Package',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tier Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: level,
                        decoration: const InputDecoration(labelText: 'Market Level Tier'),
                        items: ['L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7']
                            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: (v) => setDialogState(() => level = v ?? 'L1'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Order Amount (₹)'),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Valid amount required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Available Orders Quantity'),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Valid quantity required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: rewardCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Reward Profit (₹)'),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Valid reward required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: bonusCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Bonus Profit (₹)'),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Valid bonus required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(ctx);
                      final amt = double.parse(amountCtrl.text.trim());
                      final qty = int.parse(qtyCtrl.text.trim());
                      final rew = double.parse(rewardCtrl.text.trim());
                      final bon = double.parse(bonusCtrl.text.trim());

                      bool ok;
                      if (isEditing) {
                        ok = await ref.read(adminProvider.notifier).updatePackage(
                              id: pkg.id,
                              orderAmount: amt,
                              orderQuantity: qty,
                              reward: rew,
                              bonus: bon,
                              level: level,
                            );
                      } else {
                        ok = await ref.read(adminProvider.notifier).createPackage(
                              orderAmount: amt,
                              orderQuantity: qty,
                              reward: rew,
                              bonus: bon,
                              level: level,
                              status: 'active',
                            );
                      }
                      if (context.mounted && ok) {
                        CustomSnackBar.showSuccess(
                          context: context,
                          message: isEditing ? 'Package updated successfully!' : 'New package created!',
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEditing ? 'Save Changes' : 'Create Package'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
