class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode = 0,
  });
}

class AuthException extends ApiException {
  const AuthException({
    super.message = 'Session expired. Please sign in again.',
    super.statusCode = 401,
  });
}

class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}

