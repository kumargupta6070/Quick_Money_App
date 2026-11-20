import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).fetchUsers();
    });
  }

  void _triggerSearch() {
    ref
        .read(adminProvider.notifier)
        .fetchUsers(
          query: _searchController.text.trim(),
          status: _selectedStatus,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminState = ref.watch(adminProvider);
    final users = adminState.users;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Directory & Risk',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: AnimatedAmbientBackground(
        child: Column(
          children: [
            // Search & Filter Box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _triggerSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search by Mobile, Email, Invite Code...',
                      prefixIcon: const Icon(LucideIcons.search, size: 18),
                      suffixIcon: IconButton(
                        icon: const Icon(LucideIcons.arrowRight, size: 18),
                        onPressed: _triggerSearch,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
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
                  const SizedBox(height: 8),
                  // Filter Chips (ALL, active, banned)
                  Row(
                    children: ['ALL', 'active', 'banned'].map((st) {
                      final isSelected = _selectedStatus == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(st.toUpperCase()),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedStatus = st);
                            _triggerSearch();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // User List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _triggerSearch(),
                child: users.isEmpty && !adminState.isLoading
                    ? Center(
                        child: Text(
                          'No users found matching query',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _buildUserCard(context, user, isDark)
                              .animate(
                                delay: Duration(milliseconds: 30 * index),
                              )
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

  Widget _buildUserCard(BuildContext context, AdminUserItem user, bool isDark) {
    final isBanned = user.status.toLowerCase() == 'banned';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBanned
              ? const Color(0xFFEF4444).withValues(alpha: isDark ? 0.4 : 0.3)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
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
          // Header: Email + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  user.email,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      (isBanned
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981))
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.status.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: isBanned
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Details Row
          Text(
            'Mobile: ${user.mobile}  •  Invite: ${user.inviteCode}  •  Referred By: ${user.referredBy}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 12),

          // Balance & Level Info Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wallet Balance: ${CurrencyFormatter.format(user.balance)}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10B981),
                  ),
                ),
                Text(
                  'Tier: ${user.level}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons: Freeze/Unfreeze + Adjust Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showAdjustBalanceDialog(context, user),
                icon: const Icon(LucideIcons.walletCards, size: 13),
                label: const Text('Adjust Balance'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _toggleFreezeUser(context, user),
                icon: Icon(
                  isBanned ? LucideIcons.unlock : LucideIcons.lock,
                  size: 13,
                ),
                label: Text(isBanned ? 'Unfreeze' : 'Freeze User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBanned
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleFreezeUser(BuildContext context, AdminUserItem user) async {
    final willBan = user.status.toLowerCase() != 'banned';
    final targetStatus = willBan ? 'banned' : 'active';

    final ok = await ref
        .read(adminProvider.notifier)
        .updateUserStatus(user.id, targetStatus);
    if (context.mounted && ok) {
      CustomSnackBar.showSuccess(
        context: context,
        message:
            'User has been ${willBan ? 'frozen' : 'unfrozen'} successfully',
      );
    }
  }

  void _showAdjustBalanceDialog(BuildContext context, AdminUserItem user) {
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String type = 'credit';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Adjust Balance for User',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Balance: ${CurrencyFormatter.format(user.balance)}',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Credit (+)'),
                            selected: type == 'credit',
                            selectedColor: const Color(0xFF10B981),
                            onSelected: (_) =>
                                setDialogState(() => type = 'credit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Debit (-)'),
                            selected: type == 'debit',
                            selectedColor: const Color(0xFFEF4444),
                            onSelected: (_) =>
                                setDialogState(() => type = 'debit'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount (₹)',
                      ),
                      validator: (v) => v == null || double.tryParse(v) == null
                          ? 'Valid amount required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: reasonCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Adjustment',
                        hintText: 'e.g. Promotional Bonus / Correction',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Reason is required'
                          : null,
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
                      final amt = double.parse(amountCtrl.text.trim());
                      final ok = await ref
                          .read(adminProvider.notifier)
                          .adjustUserBalance(
                            userId: user.id,
                            amount: amt,
                            type: type,
                            reason: reasonCtrl.text.trim(),
                          );
                      if (context.mounted && ok) {
                        CustomSnackBar.showSuccess(
                          context: context,
                          message: 'Balance adjusted successfully!',
                        );
                      }
                    }
                  },
                  child: const Text('Confirm Adjustment'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
