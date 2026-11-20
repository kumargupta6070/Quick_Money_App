import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/custom_snackbar.dart';

/// Broadcast Flash Announcement Button and Dialog
class AdminBroadcastButton extends ConsumerWidget {
  final bool isDark;

  const AdminBroadcastButton({super.key, required this.isDark});

  void _showBroadcastDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '📢 Broadcast Announcement',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Announcement Title',
                    hintText: 'e.g. Flash Bonus Activated!',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message Body',
                    hintText: 'Enter announcement text seen by all active traders...',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Message is required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  final ok = await ref.read(adminProvider.notifier).broadcastAnnouncement(
                        title: titleController.text.trim(),
                        message: messageController.text.trim(),
                      );
                  if (context.mounted) {
                    if (ok) {
                      CustomSnackBar.showSuccess(
                        context: context,
                        message: 'Announcement broadcasted to all users successfully!',
                        icon: LucideIcons.send,
                      );
                    } else {
                      CustomSnackBar.showError(
                        context: context,
                        message: 'Failed to broadcast announcement. Please try again.',
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Broadcast'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBroadcastDialog(context, ref);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.megaphone, size: 17, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Broadcast Announcement to All Users',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
