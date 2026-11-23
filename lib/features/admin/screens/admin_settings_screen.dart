import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/admin_change_password_card.dart';
import '../widgets/admin_kill_switches_card.dart';
import '../widgets/admin_payment_gateway_card.dart';
import '../widgets/admin_screen_hero_header.dart';
import '../widgets/admin_settings_field_card.dart';
import '../widgets/admin_signout_card.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yieldController = TextEditingController();
  final _l1Controller = TextEditingController();
  final _l2Controller = TextEditingController();
  final _l3Controller = TextEditingController();
  final _thresholdController = TextEditingController();
  final _welcomeController = TextEditingController();
  final _announcementController = TextEditingController();

  String _marketStatus = 'ONLINE';
  bool _payoutLockdown = false;
  bool _maintenanceMode = false;
  String _upiId = 'quickmoney@icici';
  String _upiAccountName = 'Quick Money FinTech Ltd';
  String _gatewayMode = 'HYBRID';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(adminProvider.notifier).fetchSettings();
      _populateFromState();
    });
  }

  void _populateFromState() {
    final settings = ref.read(adminProvider).settings;
    if (settings.isNotEmpty) {
      final yRate =
          (double.tryParse(settings['daily_yield_rate'] ?? '0.025') ?? 0.025) * 100;
      final l1 =
          (double.tryParse(settings['level1_rebate_percent'] ?? '0.05') ?? 0.05) * 100;
      final l2 =
          (double.tryParse(settings['level2_rebate_percent'] ?? '0.03') ?? 0.03) * 100;
      final l3 =
          (double.tryParse(settings['level3_rebate_percent'] ?? '0.01') ?? 0.01) * 100;

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
        _payoutLockdown = settings['payout_lockdown'] == 'true';
        _maintenanceMode = settings['maintenance_mode'] == 'true';
        _upiId = settings['upi_deposit_id'] ?? 'quickmoney@icici';
        _upiAccountName = settings['upi_account_name'] ?? 'Quick Money FinTech Ltd';
        _gatewayMode = settings['payment_gateway_mode'] ?? 'HYBRID';
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

    HapticFeedback.mediumImpact();
    CustomLoader.show(context, message: 'Deploying platform rules to live engine...');

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
      'payout_lockdown': _payoutLockdown.toString(),
      'maintenance_mode': _maintenanceMode.toString(),
      'upi_deposit_id': _upiId,
      'upi_account_name': _upiAccountName,
      'payment_gateway_mode': _gatewayMode,
    };

    final ok = await ref.read(adminProvider.notifier).saveSettings(updated);
    if (mounted) {
      CustomLoader.hide(context);
      if (ok) {
        CustomSnackBar.showTopSuccess(
          context: context,
          message: 'Platform rules deployed successfully! Changes active immediately.',
          icon: LucideIcons.badgeCheck,
        );
      } else {
        CustomSnackBar.showTopError(
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
      body: AnimatedAmbientBackground(
        darkGradientColors: const [
          Color(0xFF0A0F1D),
          Color(0xFF0F172A),
          Color(0xFF070B14),
        ],
        lightGradientColors: const [
          Color(0xFFF1F5F9),
          Color(0xFFE2E8F0),
          Color(0xFFEDF2F7),
        ],
        primaryOrbColor: const Color(0xFF0EA5E9),
        secondaryOrbColor: const Color(0xFF64748B),
        tertiaryOrbColor: const Color(0xFFEF4444),
        child: Column(
          children: [
            // 1. Signature Royal FinTech Header with HomeHeader
            const AdminScreenHeroHeader(
              title: 'Platform Rules & Config',
              icon: LucideIcons.sliders,
              badgeText: 'Live Engine',
              badgeColor: Color(0xFFF59E0B),
            ),

            // 2. Settings Form
            Expanded(
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

                      const SizedBox(height: 18),

                      // Emergency Circuit Breakers (Kill-Switches)
                      AdminKillSwitchesCard(
                        isDark: isDark,
                        marketOnline: _marketStatus == 'ONLINE',
                        payoutLockdown: _payoutLockdown,
                        maintenanceMode: _maintenanceMode,
                        onMarketToggle: (val) => setState(() => _marketStatus = val ? 'ONLINE' : 'FROZEN'),
                        onPayoutLockdownToggle: (val) => setState(() => _payoutLockdown = val),
                        onMaintenanceToggle: (val) => setState(() => _maintenanceMode = val),
                      ),

                      const SizedBox(height: 14),

                      // Dynamic Payment Gateway & UPI Settings
                      AdminPaymentGatewayCard(
                        isDark: isDark,
                        initialUpiId: _upiId,
                        initialAccountName: _upiAccountName,
                        initialPaymentMode: _gatewayMode,
                        onSave: (upi, name, mode) {
                          setState(() {
                            _upiId = upi;
                            _upiAccountName = name;
                            _gatewayMode = mode;
                          });
                          _saveSettings();
                        },
                      ),

                      const SizedBox(height: 14),

                      const SizedBox(height: 18),

                      // Yield & Auto-Return Threshold
                      _buildSectionHeader(
                        'DAILY YIELD & SETTLEMENT THRESHOLD',
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AdminSettingsFieldCard(
                              label: 'Daily Yield Rate (%)',
                              hint: '2.5',
                              controller: _yieldController,
                              icon: LucideIcons.percent,
                              accentColor: const Color(0xFF0284C7),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AdminSettingsFieldCard(
                              label: 'Min Auto-Return (₹)',
                              hint: '100.00',
                              controller: _thresholdController,
                              icon: LucideIcons.indianRupee,
                              accentColor: const Color(0xFF10B981),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AdminSettingsFieldCard(
                        label: 'Newbie Welcome Bonus (₹)',
                        hint: '51.07',
                        controller: _welcomeController,
                        icon: LucideIcons.gift,
                        accentColor: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 18),

                      // 3-Level Referral Rebates with distinct colors
                      _buildSectionHeader(
                        '3-LEVEL REFERRAL REBATE CONFIG',
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AdminSettingsFieldCard(
                              label: 'L1 Direct (%)',
                              hint: '5.0',
                              controller: _l1Controller,
                              icon: LucideIcons.userCheck,
                              accentColor: const Color(0xFF0284C7),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AdminSettingsFieldCard(
                              label: 'L2 Team (%)',
                              hint: '3.0',
                              controller: _l2Controller,
                              icon: LucideIcons.users,
                              accentColor: const Color(0xFF8B5CF6),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AdminSettingsFieldCard(
                              label: 'L3 Network (%)',
                              hint: '1.0',
                              controller: _l3Controller,
                              icon: LucideIcons.network,
                              accentColor: const Color(0xFFEC4899),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // In-App Flash Announcement
                      _buildSectionHeader(
                        'PLATFORM FLASH ANNOUNCEMENT',
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.megaphone,
                                  size: 13,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Global Broadcast Banner Text',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _announcementController,
                              maxLines: 2,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'e.g. Market hours: Mon-Fri 09:00 - 18:00...',
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Save Rules Button with Radiant Emerald Gradient
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF059669), Color(0xFF10B981)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: _saveSettings,
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.save, size: 18, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Save & Deploy Platform Rules',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Super Admin Password & Security
                      _buildSectionHeader('ADMIN SECURITY & PASSWORD', isDark),
                      const SizedBox(height: 10),
                      AdminChangePasswordCard(isDark: isDark),

                      const SizedBox(height: 14),

                      // Super Admin Sign Out Card
                      _buildSectionHeader('SUPER ADMIN ACCOUNT', isDark),
                      const SizedBox(height: 10),
                      AdminSignoutCard(isDark: isDark),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
}
