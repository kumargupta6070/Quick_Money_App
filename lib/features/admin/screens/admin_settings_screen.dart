import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _yieldController;
  late TextEditingController _l1Controller;
  late TextEditingController _l2Controller;
  late TextEditingController _l3Controller;
  late TextEditingController _thresholdController;
  late TextEditingController _welcomeController;
  late TextEditingController _announcementController;
  String _marketStatus = 'ONLINE';

  @override
  void initState() {
    super.initState();
    _yieldController = TextEditingController();
    _l1Controller = TextEditingController();
    _l2Controller = TextEditingController();
    _l3Controller = TextEditingController();
    _thresholdController = TextEditingController();
    _welcomeController = TextEditingController();
    _announcementController = TextEditingController();

    Future.microtask(() async {
      await ref.read(adminProvider.notifier).fetchSettings();
      _populateFromState();
    });
  }

  void _populateFromState() {
    final settings = ref.read(adminProvider).settings;
    if (settings.isNotEmpty) {
      final yRate =
          (double.tryParse(settings['daily_yield_rate'] ?? '0.025') ?? 0.025) *
          100;
      final l1 =
          (double.tryParse(settings['level1_rebate_percent'] ?? '0.05') ??
              0.05) *
          100;
      final l2 =
          (double.tryParse(settings['level2_rebate_percent'] ?? '0.03') ??
              0.03) *
          100;
      final l3 =
          (double.tryParse(settings['level3_rebate_percent'] ?? '0.01') ??
              0.01) *
          100;

      setState(() {
        _yieldController.text = yRate.toStringAsFixed(1);
        _l1Controller.text = l1.toStringAsFixed(1);
        _l2Controller.text = l2.toStringAsFixed(1);
        _l3Controller.text = l3.toStringAsFixed(1);
        _thresholdController.text =
            settings['profit_return_threshold'] ?? '100.00';
        _welcomeController.text = settings['welcome_bonus'] ?? '51.07';
        _announcementController.text = settings['announcement_text'] ?? '';
        _marketStatus = settings['market_status'] ?? 'ONLINE';
      });
    }
  }

  @override
  void dispose() {
    _yieldController.dispose();
    _l1Controller.dispose();
    _l2Controller.dispose();
    _l3Controller.dispose();
    _thresholdController.dispose();
    _welcomeController.dispose();
    _announcementController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    HapticFeedback.lightImpact();
    final yVal = (double.tryParse(_yieldController.text.trim()) ?? 2.5) / 100.0;
    final l1Val = (double.tryParse(_l1Controller.text.trim()) ?? 5.0) / 100.0;
    final l2Val = (double.tryParse(_l2Controller.text.trim()) ?? 3.0) / 100.0;
    final l3Val = (double.tryParse(_l3Controller.text.trim()) ?? 1.0) / 100.0;

    final updated = {
      'daily_yield_rate': yVal.toString(),
      'level1_rebate_percent': l1Val.toString(),
      'level2_rebate_percent': l2Val.toString(),
      'level3_rebate_percent': l3Val.toString(),
      'profit_return_threshold': _thresholdController.text.trim(),
      'welcome_bonus': _welcomeController.text.trim(),
      'announcement_text': _announcementController.text.trim(),
      'market_status': _marketStatus,
    };

    final ok = await ref.read(adminProvider.notifier).saveSettings(updated);
    if (mounted) {
      if (ok) {
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Platform rules updated successfully! Changes active immediately.',
          icon: LucideIcons.badgeCheck,
        );
      } else {
        CustomSnackBar.showError(
          context: context,
          message: 'Failed to update platform settings. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Platform Rules Engine',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: AnimatedAmbientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.alertTriangle,
                        size: 18,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Changes saved here immediately dictate trading yields, referral calculations, and settlement thresholds across the entire app.',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Market Status Toggle
                _buildSectionHeader(
                  'MARKET STATUS & SYSTEM AVAILABILITY',
                  isDark,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Market Trading Status',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _marketStatus == 'ONLINE'
                                ? 'Traders can buy & sell orders freely'
                                : 'Market in maintenance mode',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _marketStatus == 'ONLINE',
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (val) {
                          setState(
                            () =>
                                _marketStatus = val ? 'ONLINE' : 'MAINTENANCE',
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Yield & Auto-Return Threshold
                _buildSectionHeader(
                  'DAILY YIELD & SETTLEMENT THRESHOLD',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildFieldCard(
                  label: 'Daily Brokerage Yield (%)',
                  hint: '2.5',
                  controller: _yieldController,
                  icon: LucideIcons.trendingUp,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildFieldCard(
                  label: 'PhonePe Auto-Return Threshold (₹)',
                  hint: '100.00',
                  controller: _thresholdController,
                  icon: LucideIcons.circleDollarSign,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildFieldCard(
                  label: 'Newbie Welcome Starter Bonus (₹)',
                  hint: '51.07',
                  controller: _welcomeController,
                  icon: LucideIcons.gift,
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // Referral Commission Percentages
                _buildSectionHeader(
                  '3-TIER PERPETUAL REFERRAL REBATES (%)',
                  isDark,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildFieldCard(
                        label: 'L1 Direct (%)',
                        hint: '5.0',
                        controller: _l1Controller,
                        icon: LucideIcons.users,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFieldCard(
                        label: 'L2 Team (%)',
                        hint: '3.0',
                        controller: _l2Controller,
                        icon: LucideIcons.users,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFieldCard(
                        label: 'L3 Sub (%)',
                        hint: '1.0',
                        controller: _l3Controller,
                        icon: LucideIcons.users,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Global Announcement Banner Text
                _buildSectionHeader('HOME SCREEN GLOBAL ANNOUNCEMENT', isDark),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _announcementController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Enter global marquee text for all users...',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ).call(
                  onPressed: _saveSettings,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.save, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Save & Deploy Platform Rules',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCard({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: const Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}

extension on ButtonStyle {
  Widget call({required VoidCallback onPressed, required Widget child}) {
    return ElevatedButton(style: this, onPressed: onPressed, child: child);
  }
}
