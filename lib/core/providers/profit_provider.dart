import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/daily_detail_model.dart';
import '../mock_data/app_mock_data.dart';

class ProfitNotifier extends Notifier<DailyDetailModel> {
  @override
  DailyDetailModel build() {
    return AppMockData.dailyDetail;
  }
}

final profitProvider = NotifierProvider<ProfitNotifier, DailyDetailModel>(() {
  return ProfitNotifier();
});

