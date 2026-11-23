import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';

/// Interactive Manual UTR Deposit Verification & Approval Desk.
class AdminUtrApprovalSheet extends ConsumerStatefulWidget {
  final bool isDark;

  const AdminUtrApprovalSheet({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminUtrApprovalSheet(isDark: isDark),
    );
  }

  @override
  ConsumerState<AdminUtrApprovalSheet> createState() =>
      _AdminUtrApprovalSheetState();
}

class _AdminUtrApprovalSheetState extends ConsumerState<AdminUtrApprovalSheet> {
  List<Map<String, dynamic>> _utrs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUtrs();
  }

  Future<void> _loadUtrs() async {
    final list = await ref.read(adminProvider.notifier).fetchPendingUtrs();
    if (mounted) {
      setState(() {
        _utrs = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove(int orderId, double amount) async {
    HapticFeedback.heavyImpact();
    CustomLoader.show(context, message: 'Verifying UTR & activating RP Package...');

    final ok = await ref.read(adminProvider.notifier).approveUtr(orderId);

    if (!mounted) return;
    CustomLoader.hide(context);

    if (ok) {
      CustomSnackBar.showTopSuccess(
        context: context,
        message: 'Order #$orderId (₹$amount) approved successfully! Package activated.',
        icon: LucideIcons.checkCheck,
      );
      _loadUtrs();
    } else {
      CustomSnackBar.showTopError(context: context, message: 'Approval failed.');
    }
  }

  Future<void> _handleReject(int orderId) async {
    HapticFeedback.mediumImpact();
    CustomLoader.show(context, message: 'Rejecting UTR...');

    final ok = await ref.read(adminProvider.notifier).rejectUtr(orderId, 'Invalid UTR code');

    if (!mounted) return;
    CustomLoader.hide(context);

    if (ok) {
      CustomSnackBar.showTopWarning(
        context: context,
        message: 'Order #$orderId rejected.',
        icon: LucideIcons.xCircle,
      );
      _loadUtrs();
    }
  }

  Widget _buildUtrItem(Map<String, dynamic> item) {
    final orderId = (item['id'] as num?)?.toInt() ?? 0;
    final amount = (item['order_amount'] as num?)?.toDouble() ?? 0.0;
    final utr = item['utr_number']?.toString() ?? 'N/A';
    final pkg = item['package_name']?.toString() ?? 'RP Package';
    final user = item['user'] as Map<String, dynamic>?;
    final email = user?['email']?.toString() ?? 'Trader';
    final status = item['status']?.toString() ?? 'pending';

    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pkg,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                CurrencyFormatter.format(amount),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'User: $email • Order #$orderId',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.hash, size: 14, color: Color(0xFF0284C7)),
                const SizedBox(width: 6),
                Text(
                  'UTR: $utr',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleReject(orderId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApprove(orderId, amount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Approve & Credit'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.isDark
              ? const [Color(0xFF2A1504), Color(0xFF140A02)]
              : const [Colors.white, Color(0xFFFFFBEB)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: const Color(0xFFF59E0B).withValues(alpha: 0.45), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 4.5,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(LucideIcons.fileCheck2, color: Color(0xFF0284C7)),
                const SizedBox(width: 10),
                Text(
                  'Pending UTR Deposit Queue',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _utrs.isEmpty
                    ? Center(
                        child: Text(
                          'No pending UTR submissions right now.',
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _utrs.length,
                        itemBuilder: (_, i) => _buildUtrItem(_utrs[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
