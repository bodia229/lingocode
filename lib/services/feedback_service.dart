import 'package:flutter/services.dart';

/// Lightweight tactile + audio feedback. Mobile gets real haptics,
/// desktop/web fall back to no-op haptic + system click.
class FeedbackService {
  static bool soundEnabled = true;
  static bool hapticEnabled = true;

  static Future<void> correct() async {
    if (hapticEnabled) {
      await HapticFeedback.mediumImpact();
    }
    if (soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  static Future<void> wrong() async {
    if (hapticEnabled) {
      await HapticFeedback.heavyImpact();
    }
    if (soundEnabled) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  static Future<void> tap() async {
    if (hapticEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  static Future<void> success() async {
    if (hapticEnabled) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.mediumImpact();
    }
    if (soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }
}
