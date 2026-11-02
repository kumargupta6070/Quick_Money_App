import '../../shared/models/user_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/models/order_model.dart';
import '../../shared/models/daily_detail_model.dart';
import '../../shared/models/banner_model.dart';
import '../../shared/models/transaction_model.dart';

/// Centralized authentic mock data matching the client reference screenshots.
class AppMockData {
  // Current Logged-in User (From Screenshot 7)
  static final UserModel user = UserModel(
    id: 101,
    mobile: '919835913180',
    inviteCode: 'xOrZx2yO',
    balance: 51.07,
    level: 'L1',
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  // Bound Wallet (From Screenshot 5)
  static final WalletModel wallet = WalletModel(
    id: 1,
    paymentApp: 'phonepe',
    upiId: '919835913180@ybl',
    status: WalletStatus.warning,
    statusDetail: 'UPI Abnormal',
    accountHolderName: 'Primary PhonePe Wallet',
    boundAt: DateTime.now().subtract(const Duration(days: 10)),
  );

  // Daily Details (From Screenshots 2 & 3)
  static final DailyDetailModel dailyDetail = DailyDetailModel(
    date: '2026-11-01',
    totalIncome: 38.75,
    purchaseNumber: 1,
    purchaseAmount: 1550.0,
    brokerage: 38.75,
    teamRebates: 0.0,
    subordinateRebates: 0.0,
    usdtRecharge: 0.0,
    trxRecharge: 0.0,
    sellNumber: 5,
    sellAmount: 1599.0,
    activityReward: 0.0,
    otherReward: 0.0,
  );

  // Home Stats Overview (From Screenshot 4)
  static const Map<String, dynamic> homeStats = {
    'buyQuantity': 1,
    'buyAmount': 1550.0,
    'sellToday': 1599.0,
    'totalRevenue': 38.75,
  };

  // Sell RP Overview (From Screenshot 5)
  static const Map<String, dynamic> sellOverview = {
    'receiptAmount': 1599.0,
    'availableTimes': 0,
  };

  // Promotional Banners (From Screenshot 4)
  static final List<BannerModel> banners = [
    const BannerModel(
      id: 1,
      title: 'Subordinate User Growth Top 10',
      subtitle: 'Compete for massive weekly community bonus pools',
      tag: 'LEADERBOARD',
      actionButtonText: 'View Ranks >',
      bannerColorHex: '#E11D48',
    ),
    const BannerModel(
      id: 2,
      title: 'USDT Top-up',
      subtitle: 'Safe • Fast • Convenient — High Returns + Rebates',
      tag: 'HOT EVENT',
      actionButtonText: 'Top up >',
      bannerColorHex: '#7C3AED',
    ),
    const BannerModel(
      id: 3,
      title: 'DEPOSIT USDT & GET EXTRA BONUS',
      subtitle: 'Get 5% instant cashback on first crypto deposit',
      tag: 'LIMITED',
      actionButtonText: 'ENTER EVENT >',
      bannerColorHex: '#0284C7',
    ),
  ];

  // Available Orders for Buy RP (From Screenshot 6)
  static final List<OrderModel> ordersL1 = [
    const OrderModel(
      id: 1001,
      orderAmount: 285.0,
      orderQuantity: 62,
      reward: 8.55,
      bonus: 2.0,
      finalRp: 295.55,
      level: 'L1',
    ),
    const OrderModel(
      id: 1002,
      orderAmount: 300.0,
      orderQuantity: 60,
      reward: 9.00,
      bonus: 2.0,
      finalRp: 311.00,
      level: 'L1',
    ),
    const OrderModel(
      id: 1003,
      orderAmount: 250.0,
      orderQuantity: 59,
      reward: 7.50,
      bonus: 2.0,
      finalRp: 259.50,
      level: 'L1',
    ),
    const OrderModel(
      id: 1004,
      orderAmount: 280.0,
      orderQuantity: 48,
      reward: 8.40,
      bonus: 2.0,
      finalRp: 290.40,
      level: 'L1',
    ),
    const OrderModel(
      id: 1005,
      orderAmount: 230.0,
      orderQuantity: 47,
      reward: 6.90,
      bonus: 2.0,
      finalRp: 238.90,
      level: 'L1',
    ),
    const OrderModel(
      id: 1006,
      orderAmount: 270.0,
      orderQuantity: 46,
      reward: 8.10,
      bonus: 2.0,
      finalRp: 280.10,
      level: 'L1',
    ),
    const OrderModel(
      id: 1007,
      orderAmount: 240.0,
      orderQuantity: 45,
      reward: 7.20,
      bonus: 2.0,
      finalRp: 249.20,
      level: 'L1',
    ),
  ];

  static List<OrderModel> getOrdersForLevel(String level) {
    if (level == 'L1') return ordersL1;
    final multiplier = (int.tryParse(level.replaceAll('L', '')) ?? 1);
    return ordersL1.map((o) {
      final newAmount = o.orderAmount * multiplier;
      final newReward = o.reward * multiplier;
      final newBonus = o.bonus * multiplier;
      return OrderModel(
        id: o.id + (multiplier * 1000),
        orderAmount: newAmount,
        orderQuantity: o.orderQuantity,
        reward: newReward,
        bonus: newBonus,
        finalRp: newAmount + newReward + newBonus,
        level: level,
      );
    }).toList();
  }

  // Transactions History
  static final List<TransactionModel> transactions = [
    TransactionModel(
      id: 501,
      type: TransactionType.payout,
      amount: 1650.0,
      profit: 100.0,
      paymentMethod: 'phonepe',
      paymentDestination: '919835913180@ybl',
      status: TransactionStatus.completed,
      referenceId: 'PAY-20261101-7782',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    TransactionModel(
      id: 502,
      type: TransactionType.buy,
      amount: 1550.0,
      profit: 38.75,
      paymentMethod: 'phonepe',
      paymentSource: '919835913180@ybl',
      status: TransactionStatus.completed,
      referenceId: 'DEP-20261101-1120',
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    TransactionModel(
      id: 503,
      type: TransactionType.rebate,
      amount: 45.0,
      profit: 45.0,
      paymentMethod: 'phonepe',
      status: TransactionStatus.completed,
      referenceId: 'REB-20261031-4451',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
