import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/daily_detail_model.dart';
import '../mock_data/app_mock_data.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class ProfitNotifier extends Notifier<DailyDetailModel> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  DailyDetailModel build() {
    // Initial fetch in background
    Future.microtask(() => fetchDailyDetails());
    return AppMockData.dailyDetail;
  }

  /// Fetch live daily profit ledger from Backend API (GET /profits/daily-details)
  Future<void> fetchDailyDetails([String? date]) async {
    try {
      if (ApiEndpoints.useMockData) return;
      final res = await _apiClient.get(
        ApiEndpoints.dailyDetails,
        queryParameters: date != null ? {'date': date} : null,
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
