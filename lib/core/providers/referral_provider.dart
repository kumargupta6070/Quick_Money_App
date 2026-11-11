import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class TeamOverview {
  final double totalEarnings;
  final int level1Members;
  final int level2Members;
  final int level3Members;
  final String level1Percent;
  final String level2Percent;
  final String level3Percent;

  const TeamOverview({
    this.totalEarnings = 148.50,
    this.level1Members = 12,
    this.level2Members = 28,
    this.level3Members = 45,
    this.level1Percent = '5%',
    this.level2Percent = '3%',
    this.level3Percent = '1%',
  });

  factory TeamOverview.fromJson(Map<String, dynamic> json) {
    return TeamOverview(
      totalEarnings:
          double.tryParse(json['totalEarnings']?.toString() ?? '148.50') ??
          148.50,
      level1Members:
          int.tryParse(json['level1Members']?.toString() ?? '12') ?? 12,
      level2Members:
          int.tryParse(json['level2Members']?.toString() ?? '28') ?? 28,
      level3Members:
          int.tryParse(json['level3Members']?.toString() ?? '45') ?? 45,
      level1Percent: json['level1Percent']?.toString() ?? '5%',
      level2Percent: json['level2Percent']?.toString() ?? '3%',
      level3Percent: json['level3Percent']?.toString() ?? '1%',
    );
  }
}

class ReferralNotifier extends Notifier<TeamOverview> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  TeamOverview build() {
    // Initial fetch in background
    Future.microtask(() => fetchTeamOverview());
    return const TeamOverview();
  }

  /// Fetch live team overview from Backend API (GET /referrals/team)
  Future<void> fetchTeamOverview() async {
    try {
      if (ApiEndpoints.useMockData) return;
      final res = await _apiClient.get(ApiEndpoints.team);
      if (res.success && res.data != null) {
        state = TeamOverview.fromJson(res.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Non-blocking fallback
    }
  }
}

final referralProvider = NotifierProvider<ReferralNotifier, TeamOverview>(() {
  return ReferralNotifier();
});
