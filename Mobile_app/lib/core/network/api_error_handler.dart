import 'package:dio/dio.dart';
import 'api_exception.dart';

class ApiErrorHandler {
  static ApiException handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return const NetworkException(
            message: 'Unable to connect to server. Please check your internet connection.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String? extractedMessage;

          if (responseData is Map<String, dynamic>) {
            if (responseData['message'] != null &&
                responseData['message'].toString().trim().isNotEmpty) {
              extractedMessage = responseData['message'].toString().trim();
            } else if (responseData['error'] != null &&
                responseData['error'].toString().trim().isNotEmpty) {
              extractedMessage = responseData['error'].toString().trim();
            } else if (responseData['msg'] != null &&
                responseData['msg'].toString().trim().isNotEmpty) {
              extractedMessage = responseData['msg'].toString().trim();
            } else if (responseData['errors'] != null) {
              final errs = responseData['errors'];
              if (errs is List && errs.isNotEmpty) {
                extractedMessage = errs.first.toString().trim();
              } else if (errs is Map && errs.isNotEmpty) {
                extractedMessage = errs.values.first.toString().trim();
              }
            }
          } else if (responseData is String && responseData.trim().isNotEmpty) {
            final trimmed = responseData.trim();
            if (!trimmed.startsWith('<') && !trimmed.contains('<!DOCTYPE')) {
              extractedMessage = trimmed;
            }
          }

          final message = extractedMessage ?? _defaultMessageForStatus(statusCode);

          if (statusCode == 401) {
            return AuthException(message: message, statusCode: statusCode);
          }
          return ApiException(
            message: message,
            statusCode: statusCode,
            data: responseData,
          );
        case DioExceptionType.cancel:
          return const ApiException(message: 'Request was cancelled.');
        default:
          return const UnknownApiException(
            message: 'Network request failed. Please try again.',
          );
      }
    }

    final rawMessage = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    return UnknownApiException(
      message: rawMessage.isNotEmpty ? rawMessage : 'An unexpected error occurred. Please try again.',
    );
  }

  static String _defaultMessageForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your details and try again.';
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return 'Requested service or resource not found.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Server is temporarily busy. Please try again in a moment.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

