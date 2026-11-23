import 'package:flutter/services.dart';

/// Sound and Sensory Haptic Feedback Service for FinTech interactions
class SoundService {
  static bool _soundEnabled = true;
  static bool _hapticsEnabled = true;

  static bool get soundEnabled => _soundEnabled;
  static bool get hapticsEnabled => _hapticsEnabled;

  static void setSoundEnabled(bool value) => _soundEnabled = value;
  static void setHapticsEnabled(bool value) => _hapticsEnabled = value;

  /// 1. Standard Button & Interactive element tap
  static void lightTap() {
    if (!_hapticsEnabled) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// 2. Tab & Screen Switch tactile transition
  static void tabSwitch() {
    if (!_hapticsEnabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// 3. Medium confirmation (Dialog open, toggle switch)
  static void mediumImpact() {
    if (!_hapticsEnabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// 4. PhonePe Payment Successful Celebration
  static void paymentSuccess() {
    if (_hapticsEnabled) {
      try {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 120), () {
          HapticFeedback.mediumImpact();
        });
        Future.delayed(const Duration(milliseconds: 240), () {
          HapticFeedback.heavyImpact();
        });
      } catch (_) {}
    }
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// 5. Daily Trading Yield & Profit Credited
  static void profitCredited() {
    if (_hapticsEnabled) {
      try {
        HapticFeedback.mediumImpact();
        Future.delayed(const Duration(milliseconds: 100), () {
          HapticFeedback.lightImpact();
        });
      } catch (_) {}
    }
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// 6. Automatic ₹100 PhonePe Payout Auto-Return Cash Settle
  static void cashSettled() {
    if (_hapticsEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// 7. Error or Dispute alert
  static void alertError() {
    if (!_hapticsEnabled) return;
    try {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 80), () {
        HapticFeedback.heavyImpact();
      });
    } catch (_) {}
  }
}
