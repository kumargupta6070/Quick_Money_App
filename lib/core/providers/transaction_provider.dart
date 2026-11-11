import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/transaction_model.dart';
import '../mock_data/app_mock_data.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'user_provider.dart';

class TransactionNotifier extends Notifier<List<TransactionModel>> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  List<TransactionModel> build() {
    // Initial fetch from live backend
    Future.microtask(() => fetchTransactions());
    return List.from(AppMockData.transactions);
  }

  /// Fetch live transaction ledger from Backend API (GET /transactions)
  Future<void> fetchTransactions() async {
    try {
      if (ApiEndpoints.useMockData) return;
      final res = await _apiClient.get(ApiEndpoints.transactions);
      if (res.success && res.data is List) {
        final list = (res.data as List)
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          state = list;
        }
      }
    } catch (_) {
      // Non-blocking fallback
    }
  }

  /// Request manual or automated return payout to PhonePe (POST /transactions/request-payout)
  Future<bool> requestPayout({double? amount}) async {
    try {
      if (ApiEndpoints.useMockData) {
        final tx = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          type: TransactionType.payout,
          amount: amount ?? 100.0,
          profit: 0.0,
          paymentMethod: 'phonepe',
          status: TransactionStatus.completed,
          createdAt: DateTime.now(),
        );
        addTransaction(tx);
        return true;
      }

      final payload = <String, dynamic>{};
      if (amount != null) {
        payload['amount'] = amount;
      }

      final res = await _apiClient.post(
        ApiEndpoints.requestPayout,
        data: payload,
      );

      if (res.success) {
        await fetchTransactions();
        ref.read(userProvider.notifier).fetchProfile();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void addTransaction(TransactionModel tx) {
    state = [tx, ...state];
  }
}

final transactionProvider =
    NotifierProvider<TransactionNotifier, List<TransactionModel>>(() {
      return TransactionNotifier();
    });
