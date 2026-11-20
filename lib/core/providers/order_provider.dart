import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/order_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';
import 'profit_provider.dart';
import 'transaction_provider.dart';
import 'user_provider.dart';

class OrderState {
  final String selectedLevel;
  final List<OrderModel> orders;
  final bool isLoading;
  final String sortOrder; // 'low_to_high' or 'high_to_low'
  final String? errorMessage;

  const OrderState({
    this.selectedLevel = 'L1',
    this.orders = const [],
    this.isLoading = false,
    this.sortOrder = 'low_to_high',
    this.errorMessage,
  });

  OrderState copyWith({
    String? selectedLevel,
    List<OrderModel>? orders,
    bool? isLoading,
    String? sortOrder,
    String? errorMessage,
  }) {
    return OrderState(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      sortOrder: sortOrder ?? this.sortOrder,
      errorMessage: errorMessage,
    );
  }
}

class OrderNotifier extends Notifier<OrderState> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  OrderState build() {
    // Initial fetch from live backend in background
    Future.microtask(() => fetchOrders('L1'));
    return const OrderState(
      selectedLevel: 'L1',
      orders: [],
      isLoading: true,
    );
  }

  /// Fetch live orders from backend (GET /orders?level=...&sort=...)
  Future<void> fetchOrders(String level) async {
    state = state.copyWith(isLoading: true, selectedLevel: level, errorMessage: null);

    try {
      final res = await _apiClient.get(
        ApiEndpoints.orders,
        queryParameters: {'level': level, 'sort': state.sortOrder},
      );

      if (res.success && res.data is List) {
        final list = (res.data as List)
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();

        _applySort(list, state.sortOrder);
        return;
      }

      state = state.copyWith(isLoading: false, orders: []);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        orders: [],
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        orders: [],
        errorMessage: 'Failed to load live orders.',
      );
    }
  }

  void changeLevel(String level) {
    fetchOrders(level);
  }

  void toggleSortOrder() {
    final newSort = state.sortOrder == 'low_to_high'
        ? 'high_to_low'
        : 'low_to_high';
    _applySort(List.from(state.orders), newSort);
  }

  void _applySort(List<OrderModel> list, String sortOrder) {
    if (sortOrder == 'low_to_high') {
      list.sort((a, b) => a.orderAmount.compareTo(b.orderAmount));
    } else {
      list.sort((a, b) => b.orderAmount.compareTo(a.orderAmount));
    }
    state = state.copyWith(
      orders: list,
      isLoading: false,
      sortOrder: sortOrder,
    );
  }

  Future<void> refresh() async {
    await fetchOrders(state.selectedLevel);
  }

  /// Receive order on live backend (POST /orders/:orderId/receive)
  Future<({bool success, String message})> receiveOrder(int orderId) async {
    final index = state.orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      return (
        success: false,
        message: 'Order is no longer available in the marketplace.',
      );
    }

    try {
      final res = await _apiClient.post(
        '${ApiEndpoints.orders}/$orderId/receive',
      );

      if (res.success) {
        // Refresh live orders from backend to keep counts & marketplace in sync
        await fetchOrders(state.selectedLevel);

        // Refresh user profile (so updated balance & level reflect immediately)
        ref.read(userProvider.notifier).fetchProfile();

        // Refresh profit daily details (so Today's total income, purchase data & committed funds update)
        ref.read(profitProvider.notifier).fetchDailyDetails();

        // Refresh transaction list
        ref.read(transactionProvider.notifier).fetchTransactions();

        final msg = res.message.isNotEmpty
            ? res.message
            : 'Order received successfully! Profit credited.';
        return (success: true, message: msg);
      }

      return (
        success: false,
        message: res.message.isNotEmpty
            ? res.message
            : 'Unable to receive order. Please try again.',
      );
    } on ApiException catch (e) {
      return (success: false, message: e.message);
    } catch (_) {
      return (
        success: false,
        message: 'Network request failed. Please check your connection.',
      );
    }
  }
}

final orderProvider = NotifierProvider<OrderNotifier, OrderState>(() {
  return OrderNotifier();
});
