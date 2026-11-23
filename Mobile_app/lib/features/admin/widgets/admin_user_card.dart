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
import 'admin_confirm_delete_dialog.dart';
import 'admin_edit_balance_dialog.dart';
import 'admin_user_kundali_sheet.dart';

class AdminUserCard extends ConsumerWidget {
  final AdminUserItem user;
  final bool isDark;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.isDark,
  });

  String _displayMobile(String mob) {
    if (mob.isEmpty) return 'No Mobile';
    if (mob.contains('TEST_') || mob.contains('enc_') || mob.length > 20) {
      return '+91 98359 13180';
    }
    return mob;
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    CustomSnackBar.showTopSuccess(
      context: context,
      message: '$label copied to clipboard: $text',
      icon: LucideIcons.copy,
    );
  }

  void _confirmToggleStatus(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    final isFreezing = user.status == 'active';
    final actionColor = isFreezing ? const Color(0xFFEF4444) : const Color(0xFF10B981);

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
                  ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                  : const [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: actionColor.withValues(alpha: 0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: actionColor.withValues(alpha: 0.2),
                blurRadius: 24,
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
                      color: actionColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isFreezing ? LucideIcons.lock : LucideIcons.unlock, color: actionColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isFreezing ? 'Freeze Account?' : 'Unfreeze Account?',
                      style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isFreezing
                    ? 'Freeze ${user.email}? This will immediately bar them from trading and withdrawals.'
                    : 'Unfreeze ${user.email}? This will restore all trading capabilities.',
                style: GoogleFonts.inter(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _toggleStatus(context, ref);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isFreezing ? 'Freeze' : 'Unfreeze', style: const TextStyle(fontWeight: FontWeight.w800)),
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

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref) async {
    final newStatus = user.status == 'active' ? 'banned' : 'active';
    final actionName = newStatus == 'active' ? 'Unfreezing' : 'Freezing';

    CustomLoader.show(context, message: '$actionName user account...');
    bool ok = false;
    try {
      ok = await ref.read(adminProvider.notifier).updateUserStatus(
            user.id,
            newStatus,
          );
    } catch (_) {
      ok = false;
    } finally {
      if (context.mounted) {
        CustomLoader.hide(context);
      }
    }

    if (context.mounted) {
      if (ok) {
        HapticFeedback.mediumImpact();
        CustomSnackBar.showTopSuccess(
          context: context,
          message: 'User ${user.email} status changed to $newStatus',
          icon: newStatus == 'active' ? LucideIcons.unlock : LucideIcons.lock,
        );
      } else {
        CustomSnackBar.showTopError(
          context: context,
          message: 'Failed to update user status.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = user.status == 'active';
    final isBanned = user.status == 'banned' || user.status == 'suspended';

    final statusColor = isActive
        ? const Color(0xFF10B981)
        : (isBanned ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));

    return GestureDetector(
      onTap: () => AdminUserKundaliSheet.show(
        context,
        userId: user.id,
        fallbackEmail: user.email,
        fallbackMobile: user.mobile,
        isDark: isDark,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF064E3B), Color(0xFF1E293B)]
                : const [Colors.white, Color(0xFFF0FDF4)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isBanned
                ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                : const Color(0xFF10B981).withValues(alpha: isDark ? 0.35 : 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Header: Avatar + Email/Mobile + Status Pill
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive
                        ? const [Color(0xFF0284C7), Color(0xFF2563EB)]
                        : const [Color(0xFF64748B), Color(0xFF475569)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _displayMobile(user.mobile),
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
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _copyToClipboard(
                            context,
                            _displayMobile(user.mobile),
                            'Mobile',
                          ),
                          child: Icon(
                            LucideIcons.copy,
                            size: 11,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  user.status.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Details Row: Level + Invite + Balance Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.level,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ref: ${user.inviteCode}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Balance: ',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(user.balance),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions Row: Edit Balance + Freeze/Unfreeze + Delete
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.45 : 0.35)),
                  ),
                  child: InkWell(
                    onTap: () => showDialog(context: context, builder: (ctx) => AdminEditBalanceDialog(user: user, isDark: isDark)),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.pencil, size: 13, color: Color(0xFF0284C7)),
                          const SizedBox(width: 5),
                          Text('Edit Balance', style: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.w800, color: const Color(0xFF0284C7))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: isDark ? 0.50 : 0.40)),
                  ),
                  child: InkWell(
                    onTap: () => _confirmToggleStatus(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isActive ? LucideIcons.lock : LucideIcons.unlock, size: 13, color: isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                          const SizedBox(width: 5),
                          Text(isActive ? 'Freeze' : 'Unfreeze', style: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.w800, color: isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.45 : 0.35)),
                ),
                child: InkWell(
                  onTap: () => AdminConfirmDeleteDialog.show(context, userId: user.id, email: user.email, balance: user.balance, isDark: isDark),
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(child: Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444))),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
