import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/widgets/animated_ambient_background.dart';
import '../widgets/faq_card.dart';
import '../widgets/faq_category_chips.dart';
import '../widgets/faq_data.dart';
import '../widgets/faq_hero_header.dart';
import '../widgets/faq_search_bar.dart';
import '../widgets/faq_support_banner.dart';

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

  List<Map<String, dynamic>> get _filteredFaqs {
    return FaqData.allFaqs.where((faq) {
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
              child: FaqHeroHeader(isDark: isDark)
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
                    FaqSearchBar(
                      controller: _searchController,
                      searchQuery: _searchQuery,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      isDark: isDark,
                    )
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 380.ms)
                        .slideY(begin: 0.06, end: 0, delay: 80.ms),

                    const SizedBox(height: 14),

                    // Category Filter Pills
                    FaqCategoryChips(
                      selectedCategory: _selectedCategory,
                      onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
                      isDark: isDark,
                    )
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
                      child: FaqCard(item: item, isDark: isDark, index: index),
                    );
                  }, childCount: faqs.length),
                ),
              ),

            // ── 4. 24/7 Priority Live Support Banner ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: FaqSupportBanner(isDark: isDark)
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
}
