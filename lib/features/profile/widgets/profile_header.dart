import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';

class ProfileHeader extends StatelessWidget {
  final String mobile;
  final String inviteCode;
  final bool isMobileHidden;
  final VoidCallback onToggleMobile;

  const ProfileHeader({
    super.key,
    required this.mobile,
    required this.inviteCode,
    required this.isMobileHidden,
    required this.onToggleMobile,
  });

  @override
  Widget build(BuildContext context) {
    final displayMobile = isMobileHidden
        ? '${mobile.substring(0, 4)}****${mobile.substring(mobile.length - 2)}'
        : mobile;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F2B82), Color(0xFF1A44B8)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'MOBILE: $displayMobile',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onToggleMobile,
                        child: Icon(
                          isMobileHidden ? LucideIcons.eyeOff : LucideIcons.eye,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Invite Code: $inviteCode',
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: inviteCode));
                            CustomSnackBar.showSuccess(
                              context: context,
                              message: 'Invite code copied: $inviteCode',
                              icon: LucideIcons.copy,
                            );
                          },
                          child: const Icon(
                            LucideIcons.copy,
                            size: 14,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

