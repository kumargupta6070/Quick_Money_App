class AppConstants {
  // Profit Return Threshold
  static const double profitReturnThreshold = 100.0; // ₹100 profit triggers return

  // Order Levels
  static const List<String> orderLevels = [
    'L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7'
  ];

  // Referral Rebate Levels
  static const double level1RebatePercent = 5.0;
  static const double level2RebatePercent = 3.0;
  static const double level3RebatePercent = 1.0;

  // Storage Keys
  static const String keyAuthToken = 'quick_money_auth_token';
  static const String keyRefreshToken = 'quick_money_refresh_token';
  static const String keyUserSession = 'quick_money_user_session';
  static const String keyRememberMe = 'quick_money_remember_me';
}

