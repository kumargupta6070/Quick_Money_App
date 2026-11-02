import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Live scrolling / transitioning ticker of recent payouts & community activity.
class LivePayoutTicker extends StatefulWidget {
  const LivePayoutTicker({super.key});

  @override
  State<LivePayoutTicker> createState() => _LivePayoutTickerState();
}

class _LivePayoutTickerState extends State<LivePayoutTicker> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _tickerItems = [
    {
      'icon': LucideIcons.arrowUpRight,
      'color': const Color(0xFF10B981),
      'user': 'User 98***3180',
      'action': 'received ₹1,650 PhonePe Return',
      'tag': '+₹100 Profit',
    },
    {
      'icon': LucideIcons.shoppingBag,
      'color': const Color(0xFF00E5FF),
      'user': 'User 91***4420',
      'action': 'bought Level 3 RP Order Batch',
      'tag': '₹2,500 Trade',
    },
    {
      'icon': LucideIcons.gift,
      'color': const Color(0xFFF59E0B),
      'user': 'User 97***8902',
      'action': 'received Level-1 Referral Rebate',
      'tag': '+₹125 Bonus',
    },
    {
      'icon': LucideIcons.zap,
      'color': const Color(0xFF10B981),
      'user': 'User 93***6614',
      'action': 'received ₹3,200 PhonePe Return',
      'tag': '+₹200 Profit',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _tickerItems.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _tickerItems[_currentIndex];

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
                key: ValueKey<int>(_currentIndex),
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

