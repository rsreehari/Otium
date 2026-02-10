import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// InterventionService: Platform channel for Android overlay intervention.
///
/// Design Philosophy:
/// - Overlay appears OVER current activity (Instagram, Twitter, etc.)
/// - Non-blocking: user can dismiss with single tap
/// - Breathing-aligned animation for nervous system regulation
/// - Fallback to in-app intervention if permission denied
///
/// Usage:
/// ```dart
/// final intervention = InterventionService();
/// await intervention.showIntervention();
/// ```
class InterventionService {
  static const MethodChannel _channel = MethodChannel('com.otium/intervention');

  /// Checks if the app has overlay permission (SYSTEM_ALERT_WINDOW)
  Future<bool> hasOverlayPermission() async {
    try {
      final bool? result = await _channel.invokeMethod(
        'checkOverlayPermission',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check overlay permission: ${e.message}');
      return false;
    }
  }

  /// Requests overlay permission from the user.
  /// Opens system settings where user can grant permission.
  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (e) {
      debugPrint('Failed to request overlay permission: ${e.message}');
    }
  }

  /// Shows the full-screen breathing intervention overlay.
  ///
  /// Returns true if overlay was shown, false if permission denied.
  /// When permission is denied, caller should fallback to in-app intervention.
  Future<bool> showIntervention() async {
    try {
      final bool? result = await _channel.invokeMethod('showIntervention');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to show intervention: ${e.message}');
      return false;
    }
  }

  /// Hides the intervention overlay.
  ///
  /// Called when user completes the breathing exercise or taps to dismiss.
  Future<void> hideIntervention() async {
    try {
      await _channel.invokeMethod('hideIntervention');
    } on PlatformException catch (e) {
      debugPrint('Failed to hide intervention: ${e.message}');
    }
  }

  /// Checks if we're running on Android (overlay is Android-only)
  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
}
