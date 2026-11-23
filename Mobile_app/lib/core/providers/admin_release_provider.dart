import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class AppReleaseState {
  final bool isLoading;
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final String fileSize;
  final bool isActive;
  final String? errorMessage;
  final String? successMessage;

  const AppReleaseState({
    this.isLoading = false,
    this.version = '1.0.0',
    this.downloadUrl = '',
    this.releaseNotes = '',
    this.fileSize = '28.4 MB',
    this.isActive = true,
    this.errorMessage,
    this.successMessage,
  });

  AppReleaseState copyWith({
    bool? isLoading,
    String? version,
    String? downloadUrl,
    String? releaseNotes,
    String? fileSize,
    bool? isActive,
    String? errorMessage,
    String? successMessage,
  }) {
    return AppReleaseState(
      isLoading: isLoading ?? this.isLoading,
      version: version ?? this.version,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      fileSize: fileSize ?? this.fileSize,
      isActive: isActive ?? this.isActive,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class AdminReleaseNotifier extends Notifier<AppReleaseState> {
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  AppReleaseState build() {
    return const AppReleaseState();
  }

  /// Fetch active APK release info
  Future<void> fetchRelease() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final res = await _apiClient.get(ApiEndpoints.adminAppRelease);
      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        state = state.copyWith(
          version: data['version']?.toString() ?? '1.0.0',
          downloadUrl: (data['download_url'] ?? data['downloadUrl'] ?? '').toString(),
          releaseNotes: (data['release_notes'] ?? data['releaseNotes'] ?? '').toString(),
          fileSize: (data['file_size'] ?? data['fileSize'] ?? '65.9 MB').toString(),
          isActive: data['is_active'] == true || data['isActive'] == true || data['is_active'] == 'true',
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Update APK release info (Syncs immediately with React landing page)
  Future<bool> updateRelease({
    required String version,
    required String downloadUrl,
    required String releaseNotes,
    required String fileSize,
    required bool isActive,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      final res = await _apiClient.post(
        ApiEndpoints.adminAppRelease,
        data: {
          'version': version,
          'download_url': downloadUrl,
          'downloadUrl': downloadUrl,
          'release_notes': releaseNotes,
          'releaseNotes': releaseNotes,
          'file_size': fileSize,
          'fileSize': fileSize,
          'is_active': isActive,
          'isActive': isActive,
        },
      );

      if (res.success) {
        state = state.copyWith(
          version: version,
          downloadUrl: downloadUrl,
          releaseNotes: releaseNotes,
          fileSize: fileSize,
          isActive: isActive,
          isLoading: false,
          successMessage: 'APK release updated and synced live with website!',
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Direct APK binary upload by Super Admin
  Future<bool> uploadApkFile({
    required String filePath,
    required String fileName,
    String? version,
    String? releaseNotes,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );
      final formData = FormData.fromMap({
        'apk': multipartFile,
        if (version != null && version.isNotEmpty) 'version': version,
        if (releaseNotes != null && releaseNotes.isNotEmpty) 'release_notes': releaseNotes,
      });

      final res = await _apiClient.post(
        ApiEndpoints.adminUploadApk,
        data: formData,
        onSendProgress: onProgress,
      );

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        state = state.copyWith(
          version: data['version']?.toString() ?? version ?? state.version,
          downloadUrl: (data['download_url'] ?? data['downloadUrl'] ?? 'https://quick-money-api.onrender.com/downloads/quick-money.apk').toString(),
          fileSize: (data['file_size'] ?? data['fileSize'] ?? state.fileSize).toString(),
          releaseNotes: (data['release_notes'] ?? data['releaseNotes'] ?? state.releaseNotes).toString(),
          isActive: true,
          isLoading: false,
          successMessage: res.message.isNotEmpty
              ? res.message
              : 'APK uploaded & synced live with website!',
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Reset / Delete APK release metadata
  Future<bool> deleteRelease() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final res = await _apiClient.delete(ApiEndpoints.adminAppRelease);
      if (res.success) {
        state = const AppReleaseState(isLoading: false, successMessage: 'APK release deleted from website.');
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: res.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final adminReleaseProvider =
    NotifierProvider<AdminReleaseNotifier, AppReleaseState>(
      AdminReleaseNotifier.new,
    );
