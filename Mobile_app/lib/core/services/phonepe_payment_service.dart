import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';

/// Data class holding PhonePe initiation response
class PhonePeInitiateResult {
  final bool success;
  final String? merchantTransactionId;
  final double amount;
  final String? redirectUrl;
  final String? intentUrl;
  final String environment;
  final String message;

  const PhonePeInitiateResult({
    required this.success,
    this.merchantTransactionId,
    this.amount = 0.0,
    this.redirectUrl,
    this.intentUrl,
    this.environment = 'SANDBOX',
    required this.message,
  });
}

/// Service managing PhonePe Gateway integrations (UPI Intent, Web Checkout, Status Polling)
class PhonePePaymentService {
  final ApiClient _apiClient;

  PhonePePaymentService(this._apiClient);

  /// 1. Initiate PhonePe Payment on Backend
  Future<PhonePeInitiateResult> initiatePayment({
    required double amount,
    int? orderPackageId,
    String? mobileNumber,
  }) async {
    try {
      final payload = <String, dynamic>{'amount': amount};
      if (orderPackageId != null) payload['orderPackageId'] = orderPackageId;
      if (mobileNumber != null && mobileNumber.isNotEmpty) {
        payload['mobileNumber'] = mobileNumber;
      }

      final res = await _apiClient.post(
        ApiEndpoints.phonePeInitiate,
        data: payload,
      );

      if (res.success && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        return PhonePeInitiateResult(
          success: true,
          merchantTransactionId: data['merchantTransactionId'] as String?,
          amount: (data['amount'] as num?)?.toDouble() ?? amount,
          redirectUrl: data['redirectUrl'] as String?,
          intentUrl: data['intentUrl'] as String?,
          environment: (data['environment'] as String?) ?? 'SANDBOX',
          message: res.message.isNotEmpty
              ? res.message
              : 'PhonePe payment initialized',
        );
      }

      return PhonePeInitiateResult(
        success: false,
        message: res.message.isNotEmpty
            ? res.message
            : 'Failed to initialize PhonePe payment.',
      );
    } on ApiException catch (e) {
      return PhonePeInitiateResult(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return PhonePeInitiateResult(
        success: false,
        message: 'Network error connecting to PhonePe gateway.',
      );
    }
  }

  /// 2. Launch PhonePe Checkout (First try Native UPI Intent, then Web Fallback)
  Future<bool> launchPhonePeCheckout({
    required String? intentUrl,
    required String? redirectUrl,
  }) async {
    // Attempt 1: Native PhonePe UPI Intent (Mobile Flipkart/PhonePe app)
    if (!kIsWeb && intentUrl != null && intentUrl.isNotEmpty) {
      try {
        final intentUri = Uri.parse(intentUrl);
        final canLaunch = await canLaunchUrl(intentUri);
        if (canLaunch) {
          final launched = await launchUrl(
            intentUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return true;
        }
      } catch (e) {
        debugPrint('PhonePe Intent launch fallback triggered: $e');
      }
    }

    // Attempt 2: Web Checkout / Simulator Redirect URL
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      try {
        final redirectUri = Uri.parse(redirectUrl);
        return await launchUrl(
          redirectUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('PhonePe Redirect launch failed: $e');
      }
    }

    return false;
  }

  /// 3. Check Payment Status from Backend
  Future<({bool success, String status, String message})> checkStatus(
    String merchantTxnId,
  ) async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.phonePeStatus(merchantTxnId),
      );

      if (res.success && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        final status = (data['status'] as String?) ?? 'pending';
        return (
          success: status.toLowerCase() == 'completed' ||
              status.toLowerCase() == 'success',
          status: status,
          message: res.message,
        );
      }

      return (
        success: false,
        status: 'unknown',
        message: res.message,
      );
    } on ApiException catch (e) {
      return (success: false, status: 'error', message: e.message);
    } catch (_) {
      return (
        success: false,
        status: 'error',
        message: 'Could not verify payment status.',
      );
    }
  }

  /// 4. Sandbox Test Fast-Track (Only active in Sandbox environment)
  Future<({bool success, String message})> simulateSandboxSuccess(
    String merchantTxnId,
  ) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.phonePeSimulateSuccess,
        data: {'merchantTransactionId': merchantTxnId},
      );

      return (
        success: res.success,
        message: res.message.isNotEmpty
            ? res.message
            : (res.success
                ? 'Sandbox payment approved successfully!'
                : 'Sandbox simulation failed.'),
      );
    } on ApiException catch (e) {
      return (success: false, message: e.message);
    } catch (_) {
      return (
        success: false,
        message: 'Sandbox simulation request failed.',
      );
    }
  }
}

/// Riverpod provider for PhonePePaymentService
final phonePePaymentServiceProvider = Provider<PhonePePaymentService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PhonePePaymentService(apiClient);
});
