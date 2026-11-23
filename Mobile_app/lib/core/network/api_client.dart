import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'api_error_handler.dart';
import 'api_interceptor.dart';
import 'api_response.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient(SecureStorageService storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
      ),
    );
    _dio.interceptors.add(ApiInterceptor(storageService));
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromJson);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromJson);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromJson);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromJson);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path, data: data);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>, fromJson);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return ApiClient(storage);
});

