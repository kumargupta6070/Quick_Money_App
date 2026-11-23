import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/admin_release_provider.dart';
import '../../../core/utils/custom_snackbar.dart';

class AdminApkUploadCard extends ConsumerStatefulWidget {
  final bool isDark;
  final void Function({
    required String version,
    required String fileSize,
    required String downloadUrl,
  }) onUploadComplete;

  const AdminApkUploadCard({
    super.key,
    required this.isDark,
    required this.onUploadComplete,
  });

  @override
  ConsumerState<AdminApkUploadCard> createState() => _AdminApkUploadCardState();
}

class _AdminApkUploadCardState extends ConsumerState<AdminApkUploadCard> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedFileName;
  String? _selectedFileSize;

  Future<void> _pickAndUploadApk() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk'],
      );

      if (files.isEmpty) return;
      final file = files.first;
      final path = file.path;

      if (path == null) {
        if (!mounted) return;
        CustomSnackBar.showTopError(
          context: context,
          message: 'Unable to access file path. Please select from local storage.',
        );
        return;
      }

      final bytes = file.lengthSync() ?? await file.length() ?? 0;
      final sizeMb = (bytes / (1024 * 1024)).toStringAsFixed(1) + ' MB';
      String detectedVersion = '1.0.1';
      final versionMatch = RegExp(r'v?(\d+\.\d+(\.\d+)?)', caseSensitive: false)
          .firstMatch(file.name);
      if (versionMatch != null) {
        detectedVersion = versionMatch.group(1) ?? '1.0.1';
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.05;
        _selectedFileName = file.name;
        _selectedFileSize = sizeMb;
      });

      final success = await ref.read(adminReleaseProvider.notifier).uploadApkFile(
        filePath: path,
        fileName: file.name,
        version: detectedVersion,
        onProgress: (sent, total) {
          if (total > 0 && mounted) {
            setState(() {
              _uploadProgress = sent / total;
            });
          }
        },
      );

      if (!mounted) return;
      setState(() => _isUploading = false);

      if (success) {
        final release = ref.read(adminReleaseProvider);
        widget.onUploadComplete(
          version: release.version,
          fileSize: release.fileSize,
          downloadUrl: release.downloadUrl,
        );
        CustomSnackBar.showTopSuccess(
          context: context,
          message: 'APK file uploaded! Live sync with website complete.',
        );
      } else {
        final err = ref.read(adminReleaseProvider).errorMessage ?? 'Upload failed';
        CustomSnackBar.showTopError(context: context, message: err);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      CustomSnackBar.showTopError(
        context: context,
        message: 'Error picking/uploading APK: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101B2E) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.fileUp,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direct APK File Upload',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Auto-calculates file size, version & deploys live',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedFileName != null && _isUploading) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$_selectedFileName${_selectedFileSize != null ? ' ($_selectedFileSize)' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                ),
                Text(
                  '${(_uploadProgress * 100).toInt()}%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                minHeight: 6,
              ),
            ),
          ],
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _isUploading ? null : _pickAndUploadApk,
            icon: _isUploading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(LucideIcons.hardDriveUpload, size: 16),
            label: Text(
              _isUploading ? 'Uploading APK File...' : 'Select & Upload .APK File',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
