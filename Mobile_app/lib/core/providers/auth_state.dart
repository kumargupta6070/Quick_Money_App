class LoginResponse {
  final bool success;
  final bool requiresOtp;
  final String? email;
  final String? mobile;
  final String? message;
  final String? error;

  const LoginResponse({
    required this.success,
    this.requiresOtp = false,
    this.email,
    this.mobile,
    this.message,
    this.error,
  });
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? error;
  final String? role; // 'user' or 'admin'
  final String? mobile;
  final String? email;
  final double balance;
  final String level;
  final String? inviteCode;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.error,
    this.role = 'user',
    this.mobile,
    this.email,
    this.balance = 0.0,
    this.level = 'L1',
    this.inviteCode,
  });

  bool get isAdmin => role == 'admin';

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? error,
    String? role,
    String? mobile,
    String? email,
    double? balance,
    String? level,
    String? inviteCode,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      error: error,
      role: role ?? this.role,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      level: level ?? this.level,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}
