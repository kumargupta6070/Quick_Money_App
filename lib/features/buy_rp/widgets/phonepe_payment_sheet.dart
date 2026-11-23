import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/order_provider.dart';
import '../../../core/providers/profit_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/phonepe_payment_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/models/order_model.dart';
import 'phonepe_payment_status_view.dart';

/// Interactive, animated PhonePe Payment Sheet with Dual Mode (UAT Simulator / Live Production)
class PhonePePaymentSheet extends ConsumerStatefulWidget {
  final OrderModel order;
  final bool isDark;

  const PhonePePaymentSheet({
    super.key,
    required this.order,
    required this.isDark,
  });

  static void show(
    BuildContext context, {
    required OrderModel order,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PhonePePaymentSheet(order: order, isDark: isDark),
    );
  }

  @override
  ConsumerState<PhonePePaymentSheet> createState() =>
      _PhonePePaymentSheetState();
}

class _PhonePePaymentSheetState extends ConsumerState<PhonePePaymentSheet> {
  PaymentStep _step = PaymentStep.initiating;
  String? _merchantTxnId;
  String? _redirectUrl;
  String? _intentUrl;
  String _environment = 'SANDBOX';
  String _statusMessage = 'Connecting to PhonePe Secure Gateway...';
  bool _isChecking = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPaymentSession();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _startPaymentSession() async {
    final phonePeService = ref.read(phonePePaymentServiceProvider);
    final user = ref.read(userProvider);

    final result = await phonePeService.initiatePayment(
      amount: widget.order.orderAmount,
      orderPackageId: widget.order.id,
      mobileNumber: user.mobile,
    );

    if (!mounted) return;

    if (result.success && result.merchantTransactionId != null) {
      setState(() {
        _merchantTxnId = result.merchantTransactionId;
        _redirectUrl = result.redirectUrl;
        _intentUrl = result.intentUrl;
        _environment = result.environment;
        _step = PaymentStep.awaiting;
        _statusMessage =
            'Payment session initialized. Please complete payment on PhonePe.';
      });

      // Auto-launch PhonePe checkout
      await phonePeService.launchPhonePeCheckout(
        intentUrl: _intentUrl,
        redirectUrl: _redirectUrl,
      );

      // Start periodic status poll every 5 seconds
      _startStatusPolling();
    } else {
      setState(() {
        _step = PaymentStep.failed;
        _statusMessage = result.message;
      });
    }
  }

  void _startStatusPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPaymentStatus(silent: true);
    });
  }

  Future<void> _checkPaymentStatus({bool silent = false}) async {
    if (_merchantTxnId == null) return;
    if (!silent) setState(() => _isChecking = true);

    final phonePeService = ref.read(phonePePaymentServiceProvider);
    final res = await phonePeService.checkStatus(_merchantTxnId!);

    if (!mounted) return;
    if (!silent) setState(() => _isChecking = false);

    if (res.success) {
      _onPaymentSucceeded();
    } else if (!silent) {
      CustomSnackBar.showInfo(
        context: context,
        message: 'Payment status: ${res.status.toUpperCase()} (Awaiting PhonePe confirmation)',
      );
    }
  }

  Future<void> _simulateFastTrackSuccess() async {
    if (_merchantTxnId == null) return;
    setState(() => _isChecking = true);

    final phonePeService = ref.read(phonePePaymentServiceProvider);
    final res =
        await phonePeService.simulateSandboxSuccess(_merchantTxnId!);

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (res.success) {
      _onPaymentSucceeded();
    } else {
      CustomSnackBar.showError(
        context: context,
        message: res.message,
      );
    }
  }

  void _onPaymentSucceeded() {
    _pollingTimer?.cancel();
    SoundService.paymentSuccess();
    setState(() {
      _step = PaymentStep.success;
      _statusMessage = 'Payment confirmed! RP credited to your account.';
    });

    // Refresh live app data
    ref.read(userProvider.notifier).fetchProfile();
    ref.read(orderProvider.notifier).refresh();
    ref.read(profitProvider.notifier).fetchDailyDetails();
    ref.read(transactionProvider.notifier).fetchTransactions();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.pop(context);
      CustomSnackBar.showSuccess(
        context: context,
        message:
            '₹${widget.order.orderAmount.toStringAsFixed(2)} PhonePe Payment Confirmed! RP Package Activated!',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final order = widget.order;

    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        22,
        MediaQuery.of(context).viewInsets.bottom + 26,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0xFF5F259F).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F259F).withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: PhonePe Brand & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5F259F), Color(0xFF7B2CBF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5F259F)
                              .withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'पे',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PhonePe Gateway',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_environment == 'SANDBOX') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B)
                            .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        'TEST UAT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.x, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white10
                      : const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.all(6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Central Status Graphic
          PhonePePaymentStatusView(
            step: _step,
            isDark: isDark,
            orderAmount: widget.order.orderAmount,
            statusMessage: _statusMessage,
          ),

          const SizedBox(height: 16),

          // Order summary card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Package Tier',
                  '${order.level} RP Order',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Order Investment',
                  CurrencyFormatter.format(order.orderAmount),
                  isDark,
                  isBold: true,
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Credited RP Yield',
                  '${order.finalRp.toStringAsFixed(1)} RP',
                  isDark,
                  valueColor: const Color(0xFF10B981),
                ),
                if (_merchantTxnId != null) ...[
                  const Divider(height: 16),
                  _buildSummaryRow(
                    'Txn Ref',
                    _merchantTxnId!,
                    isDark,
                    fontSize: 11,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          if (_step == PaymentStep.awaiting) ...[
            ElevatedButton.icon(
              onPressed: () {
                ref.read(phonePePaymentServiceProvider).launchPhonePeCheckout(
                      intentUrl: _intentUrl,
                      redirectUrl: _redirectUrl,
                    );
              },
              icon: const Icon(LucideIcons.externalLink, size: 16),
              label: const Text('Open PhonePe / Checkout Page'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F259F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 10),

            // In Sandbox mode, show fast-track testing button
            if (_environment == 'SANDBOX') ...[
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _simulateFastTrackSuccess,
                icon: const Icon(LucideIcons.zap, size: 16),
                label: Text(
                  _isChecking
                      ? 'Simulating Payment...'
                      : '⚡ Instant Sandbox Approve (Fast-Track Test)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 10),
            ],

            OutlinedButton.icon(
              onPressed: _isChecking ? null : () => _checkPaymentStatus(),
              icon: _isChecking
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.refreshCw, size: 15),
              label: Text(
                _isChecking ? 'Verifying...' : 'Check Payment Status',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: BorderSide(
                  color: isDark
                      ? Colors.white24
                      : const Color(0xFFCBD5E1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ] else if (_step == PaymentStep.failed) ...[
            ElevatedButton(
              onPressed: _startPaymentSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Retry Payment Initiation'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    Color? valueColor,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ??
                (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
