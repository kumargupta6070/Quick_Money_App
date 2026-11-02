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
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'No internet connection', super.statusCode = 0});
}

class AuthException extends ApiException {
  const AuthException({super.message = 'Authentication required', super.statusCode = 401});
}

class UnknownApiException extends ApiException {
  const UnknownApiException({super.message = 'An unexpected error occurred'});
}

