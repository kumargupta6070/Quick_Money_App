import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamOverview {
  final double totalEarnings;
  final int level1Members;
  final int level2Members;
  final int level3Members;

  const TeamOverview({
    this.totalEarnings = 148.50,
    this.level1Members = 12,
    this.level2Members = 28,
    this.level3Members = 45,
  });
}

class ReferralNotifier extends Notifier<TeamOverview> {
  @override
  TeamOverview build() {
    return const TeamOverview();
  }
}

final referralProvider = NotifierProvider<ReferralNotifier, TeamOverview>(() {
  return ReferralNotifier();
});

