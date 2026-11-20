import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/user_model.dart';

/// Live scrolling / transitioning ticker of recent payouts & community activity.
class LivePayoutTicker extends ConsumerStatefulWidget {
  const LivePayoutTicker({super.key});

  @override
  ConsumerState<LivePayoutTicker> createState() => _LivePayoutTickerState();
}

class _LivePayoutTickerState extends ConsumerState<LivePayoutTicker> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _maskUser(UserModel user) {
    final clean = user.mobile.replaceAll(RegExp(r'\D'), '');
    if (clean.length >= 10) {
      return 'User ${clean.substring(0, 2)}***${clean.substring(clean.length - 4)}';
    }
    return 'Active Member';
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final user = ref.watch(userProvider);
    final maskedUser = _maskUser(user);

    final List<Map<String, dynamic>> tickerItems = [];

    // 1. Live real user transactions from backend
    for (final tx in transactions.take(4)) {
      if (tx.type == TransactionType.payout) {
        tickerItems.add({
          'icon': LucideIcons.arrowUpRight,
          'color': const Color(0xFF10B981),
          'user': maskedUser,
          'action': 'received ₹${tx.amount.toStringAsFixed(0)} PhonePe Return',
          'tag': 'Success',
        });
      } else if (tx.type == TransactionType.buy) {
        tickerItems.add({
          'icon': LucideIcons.shoppingBag,
          'color': const Color(0xFF00E5FF),
          'user': maskedUser,
          'action': 'placed ₹${tx.amount.toStringAsFixed(0)} RP Order',
          'tag': tx.profit > 0 ? '+₹${tx.profit.toStringAsFixed(0)} Profit' : 'Active',
        });
      } else if (tx.type == TransactionType.rebate) {
        tickerItems.add({
          'icon': LucideIcons.gift,
          'color': const Color(0xFFF59E0B),
          'user': maskedUser,
          'action': 'received Team Referral Rebate',
          'tag': '+₹${tx.profit.toStringAsFixed(0)} Bonus',
        });
      }
    }

    // 2. Real-time platform liquidity & community broadcast items
    tickerItems.addAll([
      {
        'icon': LucideIcons.zap,
        'color': const Color(0xFF10B981),
        'user': 'Market Liquidity',
        'action': 'PhonePe Instant Settlement Active',
        'tag': 'Zero Fee',
      },
      {
        'icon': LucideIcons.shieldCheck,
        'color': const Color(0xFF00E5FF),
        'user': 'AES-256 Vault',
        'action': 'Daily Yield Distributed at 2.5% Rate',
        'tag': 'Verified',
      },
      {
        'icon': LucideIcons.gift,
        'color': const Color(0xFFF59E0B),
        'user': 'Community 3X',
        'action': 'Level-1 5% Rebate Auto-Credited',
        'tag': '+5% Rebate',
      },
    ]);

    final safeIndex = _currentIndex % tickerItems.length;
    final item = tickerItems[safeIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Live Beacon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF10B981),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF10B981),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.3, end: 1.0, duration: 500.ms),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Animated Item Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Row(
                key: ValueKey<int>(safeIndex),
                children: [
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1)),
                        children: [
                          TextSpan(
                            text: '${item['user']} ',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          TextSpan(text: '${item['action']} '),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['tag'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: item['color'] as Color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(delay: 550.ms, duration: 400.ms)
        .slideY(begin: 0.15, end: 0, delay: 550.ms, duration: 400.ms);
  }
}

