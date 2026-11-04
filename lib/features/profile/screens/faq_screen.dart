import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/utils/custom_snackbar.dart';
import '../../../shared/widgets/animated_ambient_background.dart';

/// Ultra-Designable, Colorful, and Animated FAQ & Help Center Screen
/// Features 15 comprehensive FinTech FAQs across 4 distinct colorful categories,
/// real-time search filtering, dynamic category gradient backgrounds,
/// and smooth cascading entrance animations on load & scroll.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allFaqs = [
    // ── Category 1: General & Orders ──
    {
      'id': 1,
      'category': 'Orders',
      'icon': LucideIcons.trendingUp,
      'q': 'How does Quick Money investment & RP trading work?',
      'a': 'Quick Money enables users to purchase RP trading orders backed by high-liquidity financial arbitrage. Users deposit funds in the morning to purchase RP tiers. As market transactions settle continuously throughout the day, profit accumulates. Once your accumulated profit reaches ₹100, the system automatically returns your initial amount and profit directly to your bound PhonePe UPI ID.',
      'tag': 'HOW IT WORKS',
      'accentColor': const Color(0xFFF59E0B),
      'lightBg': [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      'darkBg': [Color(0xFF261904), Color(0xFF1A1102)],
    },
    {
      'id': 2,
      'category': 'Orders',
      'icon': LucideIcons.shoppingBag,
      'q': 'What is the minimum deposit and order amount?',
      'a': 'The minimum deposit amount starts at just ₹100, making it accessible for everyone to test the platform. Order sizes range from Level 1 starter amounts (₹150 - ₹1,550) up to VIP tiers with higher daily brokerage yields of 2.5% to 5.0%.',
      'tag': 'MINIMUMS',
      'accentColor': const Color(0xFFF59E0B),
      'lightBg': [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      'darkBg': [Color(0xFF261904), Color(0xFF1A1102)],
    },
    {
      'id': 3,
      'category': 'Orders',
      'icon': LucideIcons.refreshCw,
      'q': 'How does the Sell RP and order redemption cycle work?',
      'a': 'When an RP cycle concludes or when you choose to sell orders on the "Sell RP" tab, simply choose the tier amount, verify your PhonePe destination, and confirm. The core system processes the liquidation and credits principal plus returns in real time.',
      'tag': 'SELL RP',
      'accentColor': const Color(0xFFF59E0B),
      'lightBg': [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      'darkBg': [Color(0xFF261904), Color(0xFF1A1102)],
    },
    {
      'id': 4,
      'category': 'Orders',
      'icon': LucideIcons.gift,
      'q': 'How do I claim Newbie Starter Rewards and daily bonuses?',
      'a': 'New users receive up to ₹100 in free starter bonuses! Navigate to "Newbie Rewards" from your Profile/Mine tab. You can claim Day 1 through Day 7 check-in gifts, first deposit matching bonuses, and trial order vouchers that yield instant redeemable cash.',
      'tag': 'BONUSES',
      'accentColor': const Color(0xFFF59E0B),
      'lightBg': [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      'darkBg': [Color(0xFF261904), Color(0xFF1A1102)],
    },

    // ── Category 2: Profit & Payouts ──
    {
      'id': 5,
      'category': 'Payouts',
      'icon': LucideIcons.zap,
      'q': 'When and how is my profit paid out automatically?',
      'a': 'Quick Money features an automated PhonePe settlement gateway. As soon as your cumulative daily profit reaches the ₹100 threshold, our system automatically initiates a payout directly to your bound PhonePe UPI ID. Payouts are dispatched within 0 to 15 seconds without requiring manual requests.',
      'tag': 'INSTANT PAYOUT',
      'accentColor': const Color(0xFF10B981),
      'lightBg': [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
      'darkBg': [Color(0xFF052A1B), Color(0xFF02170E)],
    },
    {
      'id': 6,
      'category': 'Payouts',
      'icon': LucideIcons.badgePercent,
      'q': 'Are there any withdrawal processing fees or admin deductions?',
      'a': 'Zero deductions! Quick Money charges 0% fees on automated withdrawals and principal returns. 100% of your initial capital and realized gains are transferred directly into your bank account via PhonePe / UPI.',
      'tag': 'ZERO FEES',
      'accentColor': const Color(0xFF10B981),
      'lightBg': [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
      'darkBg': [Color(0xFF052A1B), Color(0xFF02170E)],
    },
    {
      'id': 7,
      'category': 'Payouts',
      'icon': LucideIcons.creditCard,
      'q': 'Which payment apps are supported for auto-settlements?',
      'a': 'PhonePe is our premier recommended gateway partner for instantaneous auto-switching. We also fully support Google Pay (@okhdfcbank, @okaxis, @oksbi) and Paytm UPI (@paytm). You can configure your provider on the "Bind payment APP" screen.',
      'tag': 'GATEWAYS',
      'accentColor': const Color(0xFF10B981),
      'lightBg': [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
      'darkBg': [Color(0xFF052A1B), Color(0xFF02170E)],
    },
    {
      'id': 8,
      'category': 'Payouts',
      'icon': LucideIcons.clock,
      'q': 'What should I do if a payout is pending or delayed?',
      'a': 'Over 99.8% of remittances settle in under 15 seconds. On rare occasions of NPCI/bank server congestion, transactions might take up to 10 minutes. You can check the live reference ID in "Transaction History". If funds do not arrive, tap the 24/7 Live Support button.',
      'tag': 'DELAYS',
      'accentColor': const Color(0xFF10B981),
      'lightBg': [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
      'darkBg': [Color(0xFF052A1B), Color(0xFF02170E)],
    },

    // ── Category 3: Team & Rebates ──
    {
      'id': 9,
      'category': 'Team',
      'icon': LucideIcons.users,
      'q': 'How does the 3-Level Team Rebate mechanism work?',
      'a': 'Our 3-tier commission architecture rewards you perpetually for growing the network:\n• Level 1 (Direct Friends): 5% - 6% rebate on every order completed by your direct invitees.\n• Level 2 (Indirect Team): 3% - 4% on friends invited by your direct referrals.\n• Level 3 (Community Network): 1% - 2% on community tier members.\nAll referral commissions credit automatically in real time.',
      'tag': '3-TIER REBATES',
      'accentColor': const Color(0xFFEF4444),
      'lightBg': [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
      'darkBg': [Color(0xFF2B0E14), Color(0xFF1B070C)],
    },
    {
      'id': 10,
      'category': 'Team',
      'icon': LucideIcons.share2,
      'q': 'How do I invite friends and track daily team volume?',
      'a': 'Open the "My Team & Earnings" screen or copy your unique Invite Code directly from your profile header. Share your invitation link via WhatsApp, Telegram, or SMS. Your team dashboard provides real-time member counts, active trade volume, and total rebate earnings breakdown.',
      'tag': 'INVITE FRIENDS',
      'accentColor': const Color(0xFFEF4444),
      'lightBg': [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
      'darkBg': [Color(0xFF2B0E14), Color(0xFF1B070C)],
    },
    {
      'id': 11,
      'category': 'Team',
      'icon': LucideIcons.flame,
      'q': 'Is there a limit on how much referral commission I can earn?',
      'a': 'There is absolutely no cap! Whether you have 5 members or 5,000 members in your multi-tier network, you receive lifetime passive rebates on every single trade executed across your entire 3-level tree.',
      'tag': 'UNLIMITED EARNINGS',
      'accentColor': const Color(0xFFEF4444),
      'lightBg': [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
      'darkBg': [Color(0xFF2B0E14), Color(0xFF1B070C)],
    },

    // ── Category 4: Security & UPI ──
    {
      'id': 12,
      'category': 'Security',
      'icon': LucideIcons.alertTriangle,
      'q': 'What does "UPI Abnormal" mean and how do I fix it?',
      'a': '"UPI Abnormal" indicates that the payment gateway encountered a temporary bank rejection or an incorrect UPI ID handle when attempting auto-return. To resolve: Go to Profile > "Bind payment APP", re-enter or paste your correct PhonePe UPI ID (e.g. 919835913180@ybl), and tap "Verify & Bind Wallet".',
      'tag': 'UPI ABNORMAL',
      'accentColor': const Color(0xFF06B6D4),
      'lightBg': [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
      'darkBg': [Color(0xFF062833), Color(0xFF03161C)],
    },
    {
      'id': 13,
      'category': 'Security',
      'icon': LucideIcons.shieldCheck,
      'q': 'Is my payment data and UPI identity mathematically secure?',
      'a': 'Yes. All sensitive credentials, account names, and payout channels are encrypted using bank-grade AES-256 GCM encryption at rest and in transit. Your security keys are held in dedicated hardware enclaves and are never sold or shared with third parties.',
      'tag': 'AES-256 ENCRYPTION',
      'accentColor': const Color(0xFF06B6D4),
      'lightBg': [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
      'darkBg': [Color(0xFF062833), Color(0xFF03161C)],
    },
    {
      'id': 14,
      'category': 'Security',
      'icon': LucideIcons.smartphone,
      'q': 'Can I register multiple accounts on one mobile phone?',
      'a': 'To maintain system integrity, prevent promotional bonus abuse, and guarantee fair referral allocation, Quick Money permits strictly one verified account per mobile device and bound UPI ID.',
      'tag': 'DEVICE INTEGRITY',
      'accentColor': const Color(0xFF06B6D4),
      'lightBg': [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
      'darkBg': [Color(0xFF062833), Color(0xFF03161C)],
    },
    {
      'id': 15,
      'category': 'Security',
      'icon': LucideIcons.headphones,
      'q': 'How can I contact 24/7 Priority Customer Support?',
      'a': 'Our support desk is online 24 hours a day, 7 days a week. You can tap the floating blue headphones icon on any screen, select "Online service" from the Profile menu, or join our Official Telegram Community channel for instant priority assistance.',
      'tag': '24/7 SUPPORT',
      'accentColor': const Color(0xFF06B6D4),
      'lightBg': [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
      'darkBg': [Color(0xFF062833), Color(0xFF03161C)],
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    return _allFaqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'All' || faq['category'] == _selectedCategory;
      final matchesQuery =
          _searchQuery.isEmpty ||
          faq['q'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          faq['a'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          faq['tag'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final faqs = _filteredFaqs;

    return Scaffold(
      body: AnimatedAmbientBackground(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── 1. Royal FinTech Hero Curved Header ──
            SliverToBoxAdapter(
              child: _buildHeroHeader(context, isDark)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),
            ),

            // ── 2. Search & Category Filter Section ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    // Search Bar
                    _buildSearchBar(isDark)
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 380.ms)
                        .slideY(begin: 0.06, end: 0, delay: 80.ms),

                    const SizedBox(height: 14),

                    // Category Filter Pills
                    _buildCategoryPills(isDark)
                        .animate()
                        .fadeIn(delay: 120.ms, duration: 380.ms),
                  ],
                ),
              ),
            ),

            // ── 3. FAQ List Items with Distinct Background Colors ──
            if (faqs.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          LucideIcons.searchX,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No matching questions found',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try searching for "PhonePe", "Payout", or "Rebate"',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = faqs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildFaqCard(item, isDark, index),
                    );
                  }, childCount: faqs.length),
                ),
              ),

            // ── 4. 24/7 Priority Live Support Banner ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: _buildSupportBanner(context, isDark)
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 400.ms)
                    .slideY(begin: 0.08, end: 0, delay: 350.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Royal FinTech Hero Curved Header with Glowing Back Button
  Widget _buildHeroHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF07112E),
                  const Color(0xFF0D256B),
                  const Color(0xFF133694),
                ]
              : [
                  const Color(0xFF091A4B),
                  const Color(0xFF11359A),
                  const Color(0xFF1849D6),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D256B).withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Common Problems & FAQ',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Answers & guides on orders, payouts & rebates',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '15 Topics',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// High-Tech Search Bar
  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A30) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'Search problem, keyword, or error...',
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            LucideIcons.search,
            size: 18,
            color: Color(0xFF0284C7),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  /// Interactive Category Filter Pills
  Widget _buildCategoryPills(bool isDark) {
    final categories = [
      {
        'name': 'All',
        'icon': LucideIcons.layers,
        'color': const Color(0xFF2563EB),
      },
      {
        'name': 'Orders',
        'icon': LucideIcons.trendingUp,
        'color': const Color(0xFFF59E0B),
      },
      {
        'name': 'Payouts',
        'icon': LucideIcons.zap,
        'color': const Color(0xFF10B981),
      },
      {
        'name': 'Team',
        'icon': LucideIcons.users,
        'color': const Color(0xFFEF4444),
      },
      {
        'name': 'Security',
        'icon': LucideIcons.shieldCheck,
        'color': const Color(0xFF06B6D4),
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          final color = cat['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedCategory = cat['name'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [color, color.withValues(alpha: 0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark ? const Color(0xFF0F1A30) : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 13,
                      color: isSelected ? Colors.white : color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['name'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Individual FAQ Card with distinct Category Color Gradients & Glow
  Widget _buildFaqCard(Map<String, dynamic> item, bool isDark, int index) {
    final lightBg = item['lightBg'] as List<Color>;
    final darkBg = item['darkBg'] as List<Color>;
    final accentColor = item['accentColor'] as Color;

    return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? darkBg : lightBg,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.35 : 0.28),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.14 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              shape: const Border(),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      item['q'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.8,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['tag'] as String,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Text(
                      item['a'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        height: 1.5,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (40 + index * 30).ms, duration: 320.ms)
        .slideY(
          begin: 0.05,
          end: 0,
          delay: (40 + index * 30).ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// 24/7 Priority Live Support Banner
  Widget _buildSupportBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.40),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.headphones,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still have a question?',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Our live agents are available 24/7 for instant resolution.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              CustomSnackBar.showInfo(
                context: context,
                message: 'Connecting to 24/7 Live Customer Support Desk...',
                icon: LucideIcons.headphones,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0284C7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Live Chat',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
