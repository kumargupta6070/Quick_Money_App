import '../constants/app_config.dart';

class ApiEndpoints {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static bool get useMockData => AppConfig.useMockData;

  // 1. Auth Endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String loginVerifyOtp = '/auth/login-verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // 2. Users
  static const String profile = '/users/profile';
  static const String changePassword = '/users/change-password';
  static const String submitSupportTicket = '/users/support-ticket';
  static const String userMyTickets = '/users/my-tickets';

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
  static const String teamMembers = '/referrals/team/members';

  // 8. Notifications
  static const String notifications = '/notifications';
  static const String batchDeleteNotifications = '/notifications/batch-delete';

  // 9. Newbie Rewards
  static const String newbieRewards = '/rewards/newbie';
  static const String claimReward = '/rewards/claim';

  // 10. Admin Operations
  static const String adminStats = '/admin/stats';
  static const String adminPendingPayouts = '/admin/pending-payouts';
  static String adminSettlePayout(int id) => '/admin/payouts/$id/settle';
  static String adminPayoutReject(int id) => '/admin/payouts/$id/reject';
  static const String adminPackages = '/admin/packages';
  static String adminPackageDetail(int id) => '/admin/packages/$id';
  static const String adminUsers = '/admin/users';
  static String adminUserKundali(int id) => '/admin/users/$id/kundali';
  static String adminUserStatus(int id) => '/admin/users/$id/status';
  static String adminUserAdjustBalance(int id) =>
      '/admin/users/$id/adjust-balance';
  static String adminUserDelete(int id) => '/admin/users/$id';
  static const String adminSettings = '/admin/settings';
  static const String adminBroadcast = '/admin/broadcast';
  static const String adminPendingUtrs = '/admin/pending-utrs';
  static String adminApproveUtr(int id) => '/admin/orders/$id/approve-utr';
  static String adminRejectUtr(int id) => '/admin/orders/$id/reject-utr';
  static const String adminSupportTickets = '/admin/support-tickets';
  static String adminReplySupportTicket(int id) =>
      '/admin/support-tickets/$id/reply';
  static const String adminAuditLogs = '/admin/audit-logs';
  static const String adminSolvency = '/admin/solvency-metrics';
  static const String adminPendingOrders = '/admin/pending-orders';
  static const String adminApproveOrder = '/admin/orders/approve';
  static const String adminRejectOrder = '/admin/orders/reject';
  static const String adminTriggerYieldCycle = '/admin/yields/trigger-cycle';
  static const String adminAppRelease = '/admin/app-release';
  static const String adminUploadApk = '/admin/upload-apk';
  static const String systemAppRelease = '/system/app-release';

  // 11. Real PhonePe Payment Gateway (Dual-Mode: Sandbox / Production)
  static const String phonePeInitiate = '/payments/phonepe/initiate';
  static String phonePeStatus(String txnId) => '/payments/phonepe/status/$txnId';
  static const String phonePeSimulateSuccess =
      '/payments/phonepe/simulate-success';
}
