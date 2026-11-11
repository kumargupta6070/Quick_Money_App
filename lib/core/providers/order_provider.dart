import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/order_model.dart';
import '../mock_data/app_mock_data.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'user_provider.dart';

class OrderState {
  final String selectedLevel;
  final List<OrderModel> orders;
  final bool isLoading;
  final String sortOrder; // 'low_to_high' or 'high_to_low'

  const OrderState({
    this.selectedLevel = 'L1',
    this.orders = const [],
    this.isLoading = false,
    this.sortOrder = 'low_to_high',
  });

  OrderState copyWith({
    String? selectedLevel,
    List<OrderModel>? orders,
    bool? isLoading,
    String? sortOrder,
  }) {
    return OrderState(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class OrderNotifier extends Notifier<OrderState> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  OrderState build() {
    // Initial fetch from live backend in background
    Future.microtask(() => fetchOrders('L1'));
    return OrderState(
      selectedLevel: 'L1',
      orders: List.from(AppMockData.ordersL1),
    );
  }

  /// Fetch live orders from backend (GET /orders?level=...&sort=...)
  Future<void> fetchOrders(String level) async {
    state = state.copyWith(isLoading: true, selectedLevel: level);

    if (ApiEndpoints.useMockData) {
      final rawOrders = AppMockData.getOrdersForLevel(level);
      _applySort(rawOrders, state.sortOrder);
      return;
    }

    try {
      final res = await _apiClient.get(
        ApiEndpoints.orders,
        queryParameters: {'level': level, 'sort': state.sortOrder},
      );

      if (res.success && res.data is List) {
        final list = (res.data as List)
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();

        if (list.isNotEmpty) {
          _applySort(list, state.sortOrder);
          return;
        }
      }

      // If backend returned empty list, fallback to level mock orders
      final rawOrders = AppMockData.getOrdersForLevel(level);
      _applySort(rawOrders, state.sortOrder);
    } catch (_) {
      final rawOrders = AppMockData.getOrdersForLevel(level);
      _applySort(rawOrders, state.sortOrder);
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
  Future<bool> receiveOrder(int orderId) async {
    final index = state.orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    if (ApiEndpoints.useMockData) {
      final updatedList = List<OrderModel>.from(state.orders);
      updatedList.removeAt(index);
      state = state.copyWith(orders: updatedList);
      return true;
    }

    try {
      final res = await _apiClient.post(
        '${ApiEndpoints.orders}/$orderId/receive',
      );
      if (res.success) {
        final updatedList = List<OrderModel>.from(state.orders);
        updatedList.removeAt(index);
        state = state.copyWith(orders: updatedList);

        // Refresh user profile so updated live balance is immediately reflected
        ref.read(userProvider.notifier).fetchProfile();
        return true;
      }
      return false;
    } catch (_) {
      // Fallback local update
      final updatedList = List<OrderModel>.from(state.orders);
      updatedList.removeAt(index);
      state = state.copyWith(orders: updatedList);
      return true;
    }
  }
}

final orderProvider = NotifierProvider<OrderNotifier, OrderState>(() {
  return OrderNotifier();
});
