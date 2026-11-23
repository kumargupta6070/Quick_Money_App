import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../notification/providers/notification_provider.dart';

/// Next-Level FinTech Broadcast Modal for Super Admin announcements.
class AdminBroadcastDialog extends ConsumerStatefulWidget {
  final bool isDark;

  const AdminBroadcastDialog({super.key, required this.isDark});

  @override
  ConsumerState<AdminBroadcastDialog> createState() =>
      _AdminBroadcastDialogState();
}

class _AdminBroadcastDialogState extends ConsumerState<AdminBroadcastDialog> {
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _announcementType = 'Flash Alert';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _selectPreset(String title, String message, String type) {
    HapticFeedback.lightImpact();
    setState(() {
      _titleCtrl.text = title;
      _messageCtrl.text = message;
      _announcementType = type;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final title = _titleCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    Navigator.pop(context);
    CustomLoader.show(
      context,
      message: 'Broadcasting flash announcement to all traders...',
    );

    final ok = await ref.read(adminProvider.notifier).broadcastAnnouncement(
          title: title,
          message: message,
        );

    if (mounted) {
      CustomLoader.hide(context);
      if (ok) {
        HapticFeedback.mediumImpact();
        ref.read(notificationProvider.notifier).fetchNotifications();
        CustomSnackBar.showTopSuccess(
          context: context,
          message: 'Broadcast sent live to all platform users! 📢',
          icon: LucideIcons.megaphone,
        );
      } else {
        CustomSnackBar.showTopError(
          context: context,
          message: 'Failed to send broadcast. Check network connection.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    const themeColor = Color(0xFF8B5CF6); // Royal Violet / Purple

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      content: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF24143D), Color(0xFF130924)]
                : const [Colors.white, Color(0xFFFAF5FF)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: themeColor.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.megaphone, color: Colors.white, size: 20),
                    ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Broadcast ($_announcementType)',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.5,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Pushes in-app alert to all traders',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              // Presets Strip
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildPresetChip(
                      label: '⚡ Market Live',
                      title: 'Market Trading is Live! 🚀',
                      message: 'Daily yields & buy-in packages are active. Trade with confidence!',
                      type: 'Flash Alert',
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: '🎁 Bonus Drop',
                      title: 'Weekend Yield Bonus Active! 🎁',
                      message: 'Get extra rebate bonuses on all L1 and L2 RP orders today!',
                      type: 'Bonus Drop',
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: '🛠️ Maintenance',
                      title: 'Scheduled System Upgrade 🛠️',
                      message: 'Brief server upgrade tonight at 02:00 AM. Payouts remain safe.',
                      type: 'Maintenance',
                      color: const Color(0xFF38BDF8),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Title Field
              TextFormField(
                controller: _titleCtrl,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Announcement Title',
                  hintText: 'e.g. Server Maintenance Notice',
                  prefixIcon: const Icon(LucideIcons.bellRing, size: 16),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: themeColor, width: 1.5),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Please enter a title (minimum 3 characters)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Message Field
              TextFormField(
                controller: _messageCtrl,
                maxLines: 3,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Message Body',
                  hintText: 'Write the message you want all retail traders to receive...',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: themeColor, width: 1.5),
                  ),
                ),
                validator: (v) => (v == null || v.trim().length < 5) ? 'Enter content (min 5 chars)' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.send, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Blast Alert',
                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ],
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
  ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: 250.ms).fade();
}

  Widget _buildPresetChip({
    required String label,
    required String title,
    required String message,
    required String type,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _selectPreset(title, message, type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}
