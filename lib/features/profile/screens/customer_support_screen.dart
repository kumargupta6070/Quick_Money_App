import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/customer_support_ticket_form.dart';
import '../widgets/user_tickets_view.dart';

/// 24/7 FinTech Live Customer Support & Dispute Resolution Screen
class CustomerSupportScreen extends ConsumerStatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  ConsumerState<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends ConsumerState<CustomerSupportScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'PhonePe Deposit Issue';
  int _activeTab = 0; // 0 = Raise Ticket, 1 = My Tickets

  final List<String> _categories = [
    'PhonePe Deposit Issue',
    'Auto-Return ₹100 Settlement',
    'Referral Commission Query',
    'Account & Security Access',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    SoundService.lightTap();
    final user = ref.read(userProvider);
    final text = Uri.encodeComponent(
      'Hello Quick Money Support Team,\nI need assistance with my account.\nUser ID: ${user.id}\nMobile: ${user.mobile}\nIssue: General Inquiry',
    );
    final appUri = Uri.parse('whatsapp://send?phone=919876543210&text=$text');
    final webUri = Uri.parse('https://wa.me/919876543210?text=$text');

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        CustomSnackBar.showInfo(
          context: context,
          message: 'WhatsApp hotline: +91 98765 43210',
          icon: LucideIcons.messageCircle,
        );
      }
    }
  }

  Future<void> _launchTelegram() async {
    SoundService.lightTap();
    final uri = Uri.parse('https://t.me/quickmoney_official');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        CustomSnackBar.showInfo(
          context: context,
          message: 'Telegram: @quickmoney_official',
          icon: LucideIcons.send,
        );
      }
    }
  }

  Future<void> _submitTicket() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      CustomSnackBar.showError(
        context: context,
        message: 'Please provide both subject and details for your ticket.',
      );
      return;
    }

    CustomLoader.showOverlay(context, message: 'Logging support ticket...');

    try {
      final client = ref.read(apiClientProvider);
      final res = await client.post(
        ApiEndpoints.submitSupportTicket,
        data: {
          'category': _selectedCategory,
          'subject': subject,
          'message': message,
        },
      );

      if (!mounted) return;
      CustomLoader.dismiss(context);

      if (res.success) {
        SoundService.paymentSuccess();
        _subjectController.clear();
        _messageController.clear();
        CustomSnackBar.showSuccess(
          context: context,
          message: res.message.isNotEmpty
              ? res.message
              : 'Support ticket logged! Priority response within 2 hours.',
        );
        setState(() => _activeTab = 1); // Auto switch to My Tickets tab
      } else {
        CustomSnackBar.showError(
          context: context,
          message: res.message,
        );
      }
    } catch (_) {
      if (!mounted) return;
      CustomLoader.dismiss(context);
      CustomSnackBar.showError(
        context: context,
        message: 'Failed to submit ticket. Please reach us via WhatsApp.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: AnimatedAmbientBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeroHeader(context, isDark)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTabSwitcher(isDark),
                    const SizedBox(height: 16),
                    if (_activeTab == 0) ...[
                      _buildInstantChannels(isDark),
                      const SizedBox(height: 18),
                      CustomerSupportTicketForm(
                        subjectController: _subjectController,
                        messageController: _messageController,
                        selectedCategory: _selectedCategory,
                        categories: _categories,
                        onCategoryChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                        onSubmit: _submitTicket,
                        isDark: isDark,
                      ),
                    ] else ...[
                      UserTicketsView(isDark: isDark),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? const Color(0xFF0284C7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.filePlus,
                      size: 15,
                      color: _activeTab == 0 ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Raise Ticket',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _activeTab == 0 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _activeTab == 1 ? const Color(0xFF0284C7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.ticket,
                      size: 15,
                      color: _activeTab == 1 ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'My Tickets & Solutions',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _activeTab == 1 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF07112E),
            Color(0xFF0F2B82),
            Color(0xFF1A44B8),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white12,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Specialists Online',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '24/7 SUPPORT & ASSISTANCE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dedicated PhonePe settlement desk and instant resolution specialists.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstantChannels(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _launchWhatsApp,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF25D366).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.messageCircle, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WhatsApp Hotline',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Instant Response',
                          style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _launchTelegram,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0088CC), Color(0xFF006699)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0088CC).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.send, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Telegram Channel',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '50K+ Traders',
                          style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
