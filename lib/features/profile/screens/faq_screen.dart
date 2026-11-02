import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'q': 'How does Quick Money investment work?',
      'a': 'Users deposit funds in the morning to purchase RP orders. As transactions settle throughout the day, profit accumulates. Once your profit reaches ₹100, the system automatically returns your initial amount and profit directly to your bound PhonePe UPI ID.',
    },
    {
      'q': 'When is my profit paid out?',
      'a': 'As soon as your accumulated daily profit crosses the ₹100 threshold, our system initiates an automated payout to your PhonePe account. Payouts are usually credited within seconds.',
    },
    {
      'q': 'What does "UPI Abnormal" mean?',
      'a': 'UPI Abnormal occurs when the PhonePe UPI ID cannot receive payments due to bank downtime or invalid VPA. Simply go to "Bind payment APP" to update and re-verify your UPI ID.',
    },
    {
      'q': 'How does the 3-LEVEL Rebate Mechanism work?',
      'a': 'When your friends register with your invite code, you earn commission on every order they place: 5% on Level 1 (direct friends), 3% on Level 2 (friends of friends), and 1% on Level 3.',
    },
    {
      'q': 'Is my payment data secure?',
      'a': 'Yes, all sensitive credentials, UPI addresses, and payout logs are encrypted with military-grade AES-256 encryption at rest and in transit.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Common Problems & FAQ'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = faqs[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark
                    ? AppColors.darkCardBorder
                    : AppColors.lightCardBorder,
              ),
            ),
            child: ExpansionTile(
              shape: const Border(),
              title: Text(
                item['q']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    item['a']!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
