import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'user_provider.dart';

class RewardTask {
  final String id;
  final String title;
  final String subtitle;
  final double reward;
  final String rewardText;
  final bool isEligible;
  final bool isClaimed;
  final String actionType; // 'claimed', 'claim', 'navigate'
  final String? navigationRoute;

  const RewardTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.rewardText,
    required this.isEligible,
    required this.isClaimed,
    required this.actionType,
    this.navigationRoute,
  });

  factory RewardTask.fromJson(Map<String, dynamic> json) {
    return RewardTask(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      reward: double.tryParse(json['reward']?.toString() ?? '0') ?? 0.0,
      rewardText: json['rewardText']?.toString() ?? '₹0.00 RP',
      isEligible: json['isEligible'] == true,
      isClaimed: json['isClaimed'] == true,
      actionType: json['actionType']?.toString() ?? 'navigate',
      navigationRoute: json['navigationRoute']?.toString(),
    );
  }
}

class NewbieRewardsState {
  final int completedCount;
  final int totalTasks;
  final int progressPercent;
  final double welcomeBonusAmount;
  final List<RewardTask> tasks;
  final bool isLoading;
  final String? claimingTaskId;

  const NewbieRewardsState({
    this.completedCount = 0,
    this.totalTasks = 4,
    this.progressPercent = 0,
    this.welcomeBonusAmount = 50.0,
    this.tasks = const [],
    this.isLoading = false,
    this.claimingTaskId,
  });

  NewbieRewardsState copyWith({
    int? completedCount,
    int? totalTasks,
    int? progressPercent,
    double? welcomeBonusAmount,
    List<RewardTask>? tasks,
    bool? isLoading,
    String? claimingTaskId,
  }) {
    return NewbieRewardsState(
      completedCount: completedCount ?? this.completedCount,
      totalTasks: totalTasks ?? this.totalTasks,
      progressPercent: progressPercent ?? this.progressPercent,
      welcomeBonusAmount: welcomeBonusAmount ?? this.welcomeBonusAmount,
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      claimingTaskId: claimingTaskId,
    );
  }
}

class RewardNotifier extends Notifier<NewbieRewardsState> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  NewbieRewardsState build() {
    Future.microtask(() => fetchNewbieRewards());
    return const NewbieRewardsState(isLoading: true);
  }

  Future<void> fetchNewbieRewards() async {
    try {
      if (ApiEndpoints.useMockData) return;
      final res = await _apiClient.get(ApiEndpoints.newbieRewards);
      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final rawTasks = data['tasks'] as List<dynamic>? ?? [];
        final parsedTasks = rawTasks
            .map((t) => RewardTask.fromJson(t as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          completedCount:
              int.tryParse(data['completedCount']?.toString() ?? '0') ?? 0,
          totalTasks:
              int.tryParse(data['totalTasks']?.toString() ?? '4') ?? 4,
          progressPercent:
              int.tryParse(data['progressPercent']?.toString() ?? '0') ?? 0,
          welcomeBonusAmount:
              double.tryParse(data['welcomeBonusAmount']?.toString() ?? '50') ??
                  50.0,
          tasks: parsedTasks,
          isLoading: false,
        );
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> claimReward(String taskId) async {
    try {
      state = state.copyWith(claimingTaskId: taskId);
      final res = await _apiClient.post(
        ApiEndpoints.claimReward,
        data: {'taskId': taskId},
      );
      if (res.success) {
        await fetchNewbieRewards();
        await ref.read(userProvider.notifier).fetchProfile();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(claimingTaskId: null);
    }
  }
}

final rewardProvider =
    NotifierProvider<RewardNotifier, NewbieRewardsState>(() {
  return RewardNotifier();
});
