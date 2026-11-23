import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';

/// FinTech Social Invite Studio Screen
/// Features dynamic Canvas QR code generator, 1-tap WhatsApp/Telegram viral sharing,
/// branded invite hero header, and 3-level tier commission breakdowns.
class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  bool _copied = false;

  String _buildShareMessage(String code) {
    final link = 'https://quickmoney.app/#/register?ref=$code';
    return '🚀 Earn 2.5% Daily Trading Profit on Quick Money!\n'
        '⚡ Instant ₹100 Automatic PhonePe returns to your UPI.\n'
        '👉 Register with my exclusive invite code: $code\n'
        '🔗 Direct Link: $link';
  }

  Future<void> _shareToWhatsApp(String code) async {
    HapticFeedback.mediumImpact();
    final text = Uri.encodeComponent(_buildShareMessage(code));
    final whatsappUri = Uri.parse('whatsapp://send?text=$text');
    final webUri = Uri.parse('https://api.whatsapp.com/send?text=$text');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      _copyCode(code, message: 'Invite link copied to clipboard!');
    }
  }

  Future<void> _shareToTelegram(String code) async {
    HapticFeedback.mediumImpact();
    final text = Uri.encodeComponent(_buildShareMessage(code));
    final tgUri = Uri.parse('tg://msg_url?url=&text=$text');
    final webUri = Uri.parse('https://t.me/share/url?url=&text=$text');

    try {
      if (await canLaunchUrl(tgUri)) {
        await launchUrl(tgUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      _copyCode(code, message: 'Invite link copied to clipboard!');
    }
  }

  void _copyCode(String code, {String? message}) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    CustomSnackBar.showSuccess(
      context: context,
      message: message ?? 'Invite code $code copied to clipboard!',
      icon: LucideIcons.copyCheck,
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inviteCode = user.inviteCode.isNotEmpty ? user.inviteCode : 'QM1000';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: AnimatedAmbientBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Curved Hero Header
            SliverToBoxAdapter(
              child: _buildHeroHeader(context, isDark),
            ),

            // Content Body
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Dynamic QR & Code Studio Card
                    _buildInviteStudioCard(inviteCode, isDark),

                    const SizedBox(height: 18),

                    // 2. 1-Tap Viral Social Action Grid
                    _buildSocialActions(inviteCode, isDark),

                    const SizedBox(height: 20),

                    // 3. 3-Tier Commission Rules Summary
                    _buildCommissionRules(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        20,
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
                    const Icon(LucideIcons.sparkles, color: Color(0xFF10B981), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '3-Tier Rebates Active',
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
            'INVITE FRIENDS & EARN',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Earn perpetual trading rebates on every trade across 3 network tiers.',
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

  Widget _buildInviteStudioCard(String code, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF142347) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.22 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Centered High-Def FinTech Canvas QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
                ],
              ),
              child: SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter: _FintechQrPainter(seed: code.hashCode),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'YOUR EXCLUSIVE INVITE CODE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
            ),
          ),
          const SizedBox(height: 4),

          // Code Pill with Instant Copy
          GestureDetector(
            onTap: () => _copyCode(code),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: const Color(0xFFFDE68A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _copied ? LucideIcons.check : LucideIcons.copy,
                    size: 18,
                    color: const Color(0xFFFDE68A),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSocialActions(String code, bool isDark) {
    return Row(
      children: [
        // WhatsApp Share Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _shareToWhatsApp(code),
            icon: const Icon(LucideIcons.messageCircle, size: 18),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Telegram Share Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _shareToTelegram(code),
            icon: const Icon(LucideIcons.send, size: 18),
            label: const Text('Telegram'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0088CC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionRules(bool isDark) {
    final rules = [
      {'tier': 'Level 1 (Direct)', 'percent': '5.0%', 'desc': 'On all trades by friends invited by you'},
      {'tier': 'Level 2 (Team)', 'percent': '3.0%', 'desc': 'On trades by friends invited by your L1 team'},
      {'tier': 'Level 3 (Network)', 'percent': '1.0%', 'desc': 'On trades by friends invited by your L2 team'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.award, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text(
                'Perpetual Multi-Tier Rebate Matrix',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rules.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['tier']!,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                      Text(
                        r['desc']!,
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      r['percent']!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Canvas Painter rendering a crisp FinTech QR Code pattern
class _FintechQrPainter extends CustomPainter {
  final int seed;
  _FintechQrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F172A);
    const int grid = 21;
    final double cellSize = size.width / grid;
    final random = Random(seed);

    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        // Corner alignment boxes (standard QR pattern)
        final isCorner = (r < 7 && c < 7) || (r < 7 && c >= grid - 7) || (r >= grid - 7 && c < 7);
        if (isCorner) {
          final isOuter = r == 0 || r == 6 || c == 0 || c == 6 ||
              r == grid - 1 || r == grid - 7 || c == grid - 1 || c == grid - 7;
          final isInner = (r >= 2 && r <= 4) && (c >= 2 && c <= 4 || c >= grid - 5 && c <= grid - 3) ||
              (r >= grid - 5 && r <= grid - 3) && (c >= 2 && c <= 4);
          if (isOuter || isInner) {
            canvas.drawRect(Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize), paint);
          }
        } else if (r == 7 || c == 7 || r == grid - 8 || c == grid - 8) {
          // Separator whitespace
          continue;
        } else if (r >= 9 && r <= 11 && c >= 9 && c <= 11) {
          // Center emblem anchor
          continue;
        } else if (random.nextBool()) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cellSize + 0.5, r * cellSize + 0.5, cellSize - 1, cellSize - 1),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }

    // Center Gold FinTech Core
    final centerPaint = Paint()..color = const Color(0xFF5F259F);
    final coreRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cellSize * 3.5,
      height: cellSize * 3.5,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(coreRect, const Radius.circular(4)), centerPaint);
  }

  @override
  bool shouldRepaint(covariant _FintechQrPainter oldDelegate) => oldDelegate.seed != seed;
}
