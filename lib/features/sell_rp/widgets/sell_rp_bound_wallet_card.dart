import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../shared/models/wallet_model.dart';
import 'package:quick_money/core/theme/app_colors.dart';

class SellRpBoundWalletCard extends StatelessWidget {
  final bool isDark;
  final WalletModel wallet;
  final VoidCallback onDisconnect;

  const SellRpBoundWalletCard({
    super.key,
    required this.isDark,
    required this.wallet,
    required this.onDisconnect,
  });

  String _formatMaskedUpi(String upi) {
    final trimmed = upi.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split('@');
    if (parts.length == 2) {
      final prefix = parts[0];
      final handle = parts[1];
      if (prefix.length <= 3) return '$prefix*****@$handle';
      return '${prefix.substring(0, 3)}*****@$handle';
    }
    if (trimmed.length <= 4) return '$trimmed*****';
    return '${trimmed.substring(0, 4)}*****';
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = wallet.status == WalletStatus.active;
    final isAbnormal = wallet.status == WalletStatus.abnormal;

    final statusColor = isVerified
        ? const Color(0xFF10B981)
        : (isAbnormal ? const Color(0xFFEF4444) : const Color(0xFFD97706));

    final statusLabel = isVerified
        ? 'Verified & Active'
        : (isAbnormal ? 'UPI Abnormal' : 'Verification Required');

    final statusIcon = isVerified
        ? LucideIcons.shieldCheck
        : (isAbnormal
            ? LucideIcons.alertTriangle
            : Icons.warning_amber_rounded);

    final detailText = wallet.statusDetail?.isNotEmpty == true
        ? wallet.statusDetail!
        : (isVerified ? 'Verified via NPCI Bank Gateway' : 'Action Required');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E173D), const Color(0xFF140F2C)]
              : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.35 : 0.30),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5F259F), Color(0xFF451978)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5F259F).withValues(alpha: 0.40),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'पे',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            wallet.paymentApp.toLowerCase() == 'phonepe'
                                ? 'PhonePe Direct'
                                : wallet.paymentApp.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5F259F)
                                .withValues(alpha: isDark ? 0.30 : 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'DEFAULT UPI',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'UPI: ${_formatMaskedUpi(wallet.upiId)}',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 13, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onDisconnect,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1.2,
                  ),
                  foregroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                child: const Text(
                  'Disconnect',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isVerified
                          ? LucideIcons.checkCircle2
                          : LucideIcons.alertCircle,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Detail: $detailText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.push('/bind-payment'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 13,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : AppColors.brandPrimary,
                      ),
                    ],
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
