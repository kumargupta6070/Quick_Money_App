import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/custom_snackbar.dart';

/// Dynamic Payment Gateway & Manual QR/UPI Settings Card.
class AdminPaymentGatewayCard extends StatefulWidget {
  final bool isDark;
  final String initialUpiId;
  final String initialAccountName;
  final String initialPaymentMode;
  final void Function(String upiId, String accountName, String paymentMode) onSave;

  const AdminPaymentGatewayCard({
    super.key,
    required this.isDark,
    required this.initialUpiId,
    required this.initialAccountName,
    required this.initialPaymentMode,
    required this.onSave,
  });

  @override
  State<AdminPaymentGatewayCard> createState() => _AdminPaymentGatewayCardState();
}

class _AdminPaymentGatewayCardState extends State<AdminPaymentGatewayCard> {
  late final TextEditingController _upiController;
  late final TextEditingController _nameController;
  late String _mode;

  @override
  void initState() {
    super.initState();
    _upiController = TextEditingController(text: widget.initialUpiId);
    _nameController = TextEditingController(text: widget.initialAccountName);
    _mode = widget.initialPaymentMode;
  }

  @override
  void didUpdateWidget(covariant AdminPaymentGatewayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialUpiId != widget.initialUpiId) {
      _upiController.text = widget.initialUpiId;
    }
    if (oldWidget.initialAccountName != widget.initialAccountName) {
      _nameController.text = widget.initialAccountName;
    }
  }

  @override
  void dispose() {
    _upiController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              prefixIcon: Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark
              ? const [Color(0xFF1B1133), Color(0xFF110B22)]
              : const [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: widget.isDark ? 0.45 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: widget.isDark ? 0.2 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.qrCode, color: Color(0xFF8B5CF6), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Gateway & UPI Desk',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Zero-code live deposit gateway settings',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildField(
            label: 'ADMIN DEPOSIT UPI ID',
            controller: _upiController,
            icon: LucideIcons.atSign,
            hint: 'e.g. quickmoney@icici',
          ),
          const SizedBox(height: 10),
          _buildField(
            label: 'MERCHANT / ACCOUNT HOLDER NAME',
            controller: _nameController,
            icon: LucideIcons.userCheck,
            hint: 'e.g. Quick Money FinTech Ltd',
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onSave(_upiController.text.trim(), _nameController.text.trim(), _mode);
                CustomSnackBar.showTopSuccess(
                  context: context,
                  message: 'Deposit UPI ID updated live!',
                  icon: LucideIcons.checkCheck,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(LucideIcons.save, size: 14),
              label: Text(
                'Save Gateway Settings',
                style: GoogleFonts.spaceGrotesk(fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
