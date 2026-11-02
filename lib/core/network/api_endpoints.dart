import '../constants/app_config.dart';

class ApiEndpoints {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static bool get useMockData => AppConfig.useMockData;

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';

  // Users
  static const String profile = '/users/profile';

  // Wallets
  static const String wallet = '/wallets';
  static const String bindWallet = '/wallets/bind';

  // Orders
  static const String orders = '/orders';
  static String receiveOrder(int id) => '/orders/$id/receive';

  // Transactions & Payouts
  static const String transactions = '/transactions';

  // Daily Profits
  static const String dailyDetails = '/profits/daily-details';

  // Referrals
  static const String team = '/referrals/team';

  // Notifications
  static const String notifications = '/notifications';
}

