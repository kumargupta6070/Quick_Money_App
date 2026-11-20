import '../constants/app_config.dart';

class ApiEndpoints {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static bool get useMockData => AppConfig.useMockData;

  // 1. Auth Endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';

  // 2. Users
  static const String profile = '/users/profile';
  static const String changePassword = '/users/change-password';

  // 3. Wallets & Payment APP Bind (PhonePe)
  static const String wallet = '/wallets';
  static const String bindWallet = '/wallets/bind';
  static const String unbindWallet = '/wallets/unbind';

  // 4. Buy RP Orders
  static const String orders = '/orders';
  static const String orderPackages = '/orders/packages';
  static const String adminPaymentInfo = '/orders/admin-payment-info';
  static const String submitUtr = '/orders/submit-utr';

  // 5. Sell RP & Transactions
  static const String transactions = '/transactions';
  static const String requestPayout = '/transactions/request-payout';

  // 6. Daily Profits
  static const String dailyDetails = '/profits/daily-details';

  // 7. 3-Tier Referrals
  static const String team = '/referrals/team';

  // 8. Notifications
  static const String notifications = '/notifications';

  // 9. Newbie Rewards
  static const String newbieRewards = '/rewards/newbie';
  static const String claimReward = '/rewards/claim';

  // 10. Admin Operations
  static const String adminStats = '/admin/stats';
  static const String adminPendingOrders = '/admin/pending-orders';
  static const String adminApproveOrder = '/admin/orders/approve';
  static const String adminRejectOrder = '/admin/orders/reject';
  static const String adminPendingPayouts = '/admin/pending-payouts';
  static const String adminSettlePayout = '/admin/payouts/settle';
}
