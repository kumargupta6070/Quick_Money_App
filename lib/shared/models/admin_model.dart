/// Admin Dashboard Financial & Operational Stats Model
class AdminStats {
  final int totalUsers;
  final int activeUsers;
  final int bannedUsers;
  final int totalOrders;
  final int activePackages;
  final int completedOrders;
  final double totalPlatformVolume;
  final double totalUserBalanceFloat;
  final int pendingPayoutsCount;
  final double totalPendingPayoutsAmount;
  final double totalPayoutsSettled;
  final String marketStatus;
  final String serverTime;

  const AdminStats({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.bannedUsers = 0,
    this.totalOrders = 0,
    this.activePackages = 0,
    this.completedOrders = 0,
    this.totalPlatformVolume = 0.0,
    this.totalUserBalanceFloat = 0.0,
    this.pendingPayoutsCount = 0,
    this.totalPendingPayoutsAmount = 0.0,
    this.totalPayoutsSettled = 0.0,
    this.marketStatus = 'ONLINE',
    this.serverTime = '',
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final ov = json['overview'] as Map<String, dynamic>? ?? {};
    return AdminStats(
      totalUsers: (ov['totalUsers'] as num?)?.toInt() ?? 0,
      activeUsers: (ov['activeUsers'] as num?)?.toInt() ?? 0,
      bannedUsers: (ov['bannedUsers'] as num?)?.toInt() ?? 0,
      totalOrders: (ov['totalOrders'] as num?)?.toInt() ?? 0,
      activePackages: (ov['activePackages'] as num?)?.toInt() ?? 0,
      completedOrders: (ov['completedOrders'] as num?)?.toInt() ?? 0,
      totalPlatformVolume:
          (ov['totalPlatformVolume'] as num?)?.toDouble() ?? 0.0,
      totalUserBalanceFloat:
          (ov['totalUserBalanceFloat'] as num?)?.toDouble() ?? 0.0,
      pendingPayoutsCount: (ov['pendingPayoutsCount'] as num?)?.toInt() ?? 0,
      totalPendingPayoutsAmount:
          (ov['totalPendingPayoutsAmount'] as num?)?.toDouble() ?? 0.0,
      totalPayoutsSettled:
          (ov['totalPayoutsSettled'] as num?)?.toDouble() ?? 0.0,
      marketStatus: json['marketStatus'] as String? ?? 'ONLINE',
      serverTime: json['serverTime'] as String? ?? '',
    );
  }

  static const empty = AdminStats();
}

/// Pending PhonePe Payout Request Model
class AdminPayoutItem {
  final int id;
  final int userId;
  final String userEmail;
  final String userMobile;
  final String userInviteCode;
  final double amount;
  final double profitAccumulated;
  final String paymentMethod;
  final String destinationUpi;
  final String status;
  final String requestedAt;

  const AdminPayoutItem({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userMobile,
    required this.userInviteCode,
    required this.amount,
    required this.profitAccumulated,
    required this.paymentMethod,
    required this.destinationUpi,
    required this.status,
    required this.requestedAt,
  });

  factory AdminPayoutItem.fromJson(Map<String, dynamic> json) {
    return AdminPayoutItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userEmail: json['userEmail'] as String? ?? 'N/A',
      userMobile: json['userMobile'] as String? ?? 'N/A',
      userInviteCode: json['userInviteCode'] as String? ?? 'N/A',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      profitAccumulated: (json['profitAccumulated'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'phonepe',
      destinationUpi: json['destinationUpi'] as String? ?? 'UPI Hidden',
      status: json['status'] as String? ?? 'pending',
      requestedAt: json['requestedAt'] as String? ?? '',
    );
  }
}

/// Admin User Directory Model
class AdminUserItem {
  final int id;
  final String email;
  final String mobile;
  final String inviteCode;
  final String referredBy;
  final double balance;
  final String level;
  final String status;
  final String createdAt;

  const AdminUserItem({
    required this.id,
    required this.email,
    required this.mobile,
    required this.inviteCode,
    required this.referredBy,
    required this.balance,
    required this.level,
    required this.status,
    required this.createdAt,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      inviteCode: json['inviteCode'] as String? ?? '',
      referredBy: json['referred_by'] as String? ?? 'DIRECT',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as String? ?? 'L1',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
