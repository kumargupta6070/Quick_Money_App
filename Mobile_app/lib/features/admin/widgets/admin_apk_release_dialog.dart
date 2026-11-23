import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_release_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';

class AdminApkReleaseDialog extends ConsumerStatefulWidget {
  const AdminApkReleaseDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const AdminApkReleaseDialog(),
    );
  }

  @override
  ConsumerState<AdminApkReleaseDialog> createState() => _AdminApkReleaseDialogState();
}

class _AdminApkReleaseDialogState extends ConsumerState<AdminApkReleaseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _versionCtrl;
  late TextEditingController _urlCtrl;
  late TextEditingController _sizeCtrl;
  late TextEditingController _notesCtrl;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final release = ref.read(adminReleaseProvider);
    _versionCtrl = TextEditingController(text: release.version);
    _urlCtrl = TextEditingController(text: release.downloadUrl.isEmpty
        ? 'https://github.com/kumargupta6070/Quick_Money_App/releases/download/v1.0.0/quick-money-release.apk'
        : release.downloadUrl);
    _sizeCtrl = TextEditingController(text: release.fileSize);
    _notesCtrl = TextEditingController(text: release.releaseNotes.isEmpty
        ? 'Instant PhonePe payouts, 2-step OTP email verification, L1-L5 liquidity pools, AES-256 vault encryption, and 24/7 helpdesk.'
        : release.releaseNotes);
    _isActive = release.isActive;

    Future.microtask(() => ref.read(adminReleaseProvider.notifier).fetchRelease());
  }

  @override
  void dispose() {
    _versionCtrl.dispose();
    _urlCtrl.dispose();
    _sizeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _deployRelease() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    HapticFeedback.mediumImpact();
    CustomLoader.show(context, message: 'Deploying APK release to website...');

    final success = await ref.read(adminReleaseProvider.notifier).updateRelease(
      version: _versionCtrl.text.trim(),
      downloadUrl: _urlCtrl.text.trim(),
      releaseNotes: _notesCtrl.text.trim(),
      fileSize: _sizeCtrl.text.trim(),
      isActive: _isActive,
    );

    if (!mounted) return;
    CustomLoader.hide(context);

    if (success) {
      Navigator.of(context).pop();
      CustomSnackbar.showSuccess(
        context,
        'Live APK Release v${_versionCtrl.text.trim()} synced with website!',
      );
    } else {
      final err = ref.read(adminReleaseProvider).errorMessage ?? 'Deployment failed';
      CustomSnackbar.showError(context, err);
    }
  }

  Future<void> _deleteRelease() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete APK Release?',
          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will deactivate the dynamic APK download link on the website.',
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    CustomLoader.show(context, message: 'Deactivating APK release...');
    final success = await ref.read(adminReleaseProvider.notifier).deleteRelease();
    if (!mounted) return;
    CustomLoader.hide(context);

    if (success) {
      Navigator.of(context).pop();
      CustomSnackbar.showSuccess(context, 'APK release removed from website.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C1322) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0284C7), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.smartphone, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage Website APK Release',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Real-time sync with quickmoney.netlify.app',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            LucideIcons.x,
                            size: 20,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Version & Size Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildInput(
                            controller: _versionCtrl,
                            label: 'APK Version',
                            hint: '1.0.0',
                            icon: LucideIcons.tag,
                            isDark: isDark,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildInput(
                            controller: _sizeCtrl,
                            label: 'File Size',
                            hint: '28.4 MB',
                            icon: LucideIcons.hardDrive,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Download URL
                    _buildInput(
                      controller: _urlCtrl,
                      label: 'Direct APK Download URL',
                      hint: 'https://.../quick-money.apk',
                      icon: LucideIcons.link2,
                      isDark: isDark,
                      validator: (v) => (v == null || !v.startsWith('http')) ? 'Valid URL required' : null,
                    ),

                    const SizedBox(height: 12),

                    // Release Notes
                    _buildInput(
                      controller: _notesCtrl,
                      label: 'Release Notes (Shown on Website)',
                      hint: 'Features in this build...',
                      icon: LucideIcons.fileText,
                      isDark: isDark,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 14),

                    // Visibility Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D33) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E2E4E) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isActive ? LucideIcons.globe : LucideIcons.eyeOff,
                                size: 18,
                                color: _isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _isActive ? 'Active on Website' : 'Hidden from Website',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isActive,
                            activeColor: const Color(0xFF10B981),
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE11D48)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _deleteRelease,
                            icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFFE11D48)),
                            label: Text(
                              'Delete',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF0284C7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                            ),
                            onPressed: _deployRelease,
                            icon: const Icon(LucideIcons.uploadCloud, size: 17, color: Colors.white),
                            label: Text(
                              'Deploy to Website',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().scale(begin: const Offset(0.9, 0.9), duration: 240.ms, curve: Curves.easeOutBack);
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 12.5,
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              icon,
              size: 16,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF131D33) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF1E2E4E) : const Color(0xFFCBD5E1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF1E2E4E) : const Color(0xFFCBD5E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
