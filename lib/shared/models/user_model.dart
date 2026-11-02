class UserModel {
  final int id;
  final String mobile;
  final String inviteCode;
  final String? referredBy;
  final double balance;
  final String level;
  final String? avatar;
  final bool isVerified;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.mobile,
    required this.inviteCode,
    this.referredBy,
    required this.balance,
    this.level = 'L1',
    this.avatar,
    this.isVerified = true,
    this.createdAt,
  });

  UserModel copyWith({
    int? id,
    String? mobile,
    String? inviteCode,
    String? referredBy,
    double? balance,
    String? level,
    String? avatar,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      mobile: mobile ?? this.mobile,
      inviteCode: inviteCode ?? this.inviteCode,
      referredBy: referredBy ?? this.referredBy,
      balance: balance ?? this.balance,
      level: level ?? this.level,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile': mobile,
      'invite_code': inviteCode,
      'referred_by': referredBy,
      'balance': balance,
      'level': level,
      'avatar': avatar,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 1,
      mobile: json['mobile'] as String? ?? '',
      inviteCode: json['invite_code'] as String? ?? '',
      referredBy: json['referred_by'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      level: json['level'] as String? ?? 'L1',
      avatar: json['avatar'] as String?,
      isVerified: json['is_verified'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

