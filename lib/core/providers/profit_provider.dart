import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/daily_detail_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class ProfitNotifier extends Notifier<DailyDetailModel> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  DailyDetailModel build() {
    // Initial fetch in background from live backend
    Future.microtask(() => fetchDailyDetails());
    return const DailyDetailModel(
      date: '',
      totalIncome: 0.0,
      purchaseNumber: 0,
      purchaseAmount: 0.0,
      brokerage: 0.0,
      teamRebates: 0.0,
      subordinateRebates: 0.0,
      usdtRecharge: 0.0,
      trxRecharge: 0.0,
      sellNumber: 0,
      sellAmount: 0.0,
      activityReward: 0.0,
      otherReward: 0.0,
    );
  }

  /// Fetch live daily profit ledger from Backend API (GET /profits/daily-details)
  Future<void> fetchDailyDetails({String? date, String? filter}) async {
    try {
      if (ApiEndpoints.useMockData) return;
      final query = <String, dynamic>{};
      if (date != null && date.isNotEmpty) query['date'] = date;
      if (filter != null && filter.isNotEmpty) query['filter'] = filter;

      final res = await _apiClient.get(
        ApiEndpoints.dailyDetails,
        queryParameters: query.isNotEmpty ? query : null,
      );
      if (res.success && res.data != null) {
        final map = res.data as Map<String, dynamic>;
        state = DailyDetailModel.fromJson(map);
      }
    } catch (_) {
      // Non-blocking fallback
    }
  }
}

final profitProvider = NotifierProvider<ProfitNotifier, DailyDetailModel>(() {
  return ProfitNotifier();
});
