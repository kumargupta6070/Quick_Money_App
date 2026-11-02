import 'package:dio/dio.dart';
import 'api_exception.dart';

class ApiErrorHandler {
  static ApiException handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return const NetworkException(message: 'Connection timed out. Check your network.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String message = 'Server error ($statusCode)';

          if (responseData is Map<String, dynamic> && responseData['message'] != null) {
            message = responseData['message'].toString();
          }

          if (statusCode == 401) {
            return AuthException(message: message, statusCode: statusCode);
          }
          return ApiException(message: message, statusCode: statusCode, data: responseData);
        case DioExceptionType.cancel:
          return const ApiException(message: 'Request was cancelled');
        default:
          return const UnknownApiException();
      }
    }
    return UnknownApiException(message: error.toString());
  }
}

