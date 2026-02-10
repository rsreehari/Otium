import 'dart:collection';
import 'package:flutter/material.dart';
import '../core/utils/persistence_service.dart';
import '../models/user_profile.dart';

/// Represents a single interaction event with its weight and timestamp.
/// Used for rolling window friction calculation.
class InteractionEvent {
  final DateTime timestamp;
  final int weight;
  final String type;

  InteractionEvent({
    required this.timestamp,
    required this.weight,
    required this.type,
  });

  bool isExpired(Duration windowDuration) {
    return DateTime.now().difference(timestamp) > windowDuration;
  }
}

/// FatigueProvider implements context-aware, weighted interaction sensing.
///
/// Core Philosophy:
/// - Cognitive overload manifests as FRAGMENTATION, not duration
/// - Rapid context switching signals nervous-system strain
/// - We detect loss of cognitive continuity, NOT content
///
/// Friction Weights:
/// - Simple tap/scroll = 1 (normal interaction)
/// - Rapid tap (<500ms) = 2 (slight agitation)
/// - App switch = 3 (context break)
/// - Rapid app switch (<10s) = 5 (cognitive fragmentation)
class FatigueProvider with ChangeNotifier {
  final PersistenceService _persistence;

  /// Rolling window of interaction events (60-second window)
  final Queue<InteractionEvent> _interactionWindow = Queue<InteractionEvent>();

  /// Window duration for friction calculation
  static const Duration _windowDuration = Duration(seconds: 60);

  /// Adaptive threshold based on user's cognitive profile
  int _threshold = 40;

  /// Whether cognitive overload has been detected
  bool _isFatigued = false;

  /// Last interaction timestamp for detecting rapid interactions
  DateTime? _lastInteractionTime;

  /// Last app switch timestamp for detecting rapid context switching
  DateTime? _lastAppSwitchTime;

  FatigueProvider(this._persistence);

  /// Current friction score (sum of weights in rolling window)
  int get frictionScore {
    _pruneExpiredEvents();
    return _interactionWindow.fold(0, (sum, event) => sum + event.weight);
  }

  /// Number of events in current window (for debugging/display)
  int get interactionCount => _interactionWindow.length;

  bool get isFatigued => _isFatigued;
  int get threshold => _threshold;

  /// Update threshold based on user's cognitive profile
  void updateProfile(UserProfile profile) {
    _threshold = profile.cognitiveProfile.interactionThreshold;
    _checkThreshold();
  }

  /// Remove events that have fallen outside the 60-second window
  void _pruneExpiredEvents() {
    while (_interactionWindow.isNotEmpty &&
        _interactionWindow.first.isExpired(_windowDuration)) {
      _interactionWindow.removeFirst();
    }
  }

  /// Records a simple interaction (tap, scroll, etc.)
  ///
  /// Weight calculation:
  /// - Normal tap: weight 1
  /// - Rapid tap (<500ms since last): weight 2
  ///
  /// Rapid tapping indicates slight agitation but is not as
  /// cognitively costly as context switching.
  void incrementFriction() {
    final now = DateTime.now();
    int weight = 1;
    String type = 'tap';

    if (_lastInteractionTime != null) {
      final gap = now.difference(_lastInteractionTime!).inMilliseconds;

      if (gap < 500) {
        // Rapid fire interaction (agitation signal)
        weight = 2;
        type = 'rapid_tap';
      }
    }

    _lastInteractionTime = now;
    _addEvent(InteractionEvent(timestamp: now, weight: weight, type: type));
  }

  /// Records an app switch event (user left and returned to Otium).
  ///
  /// Context switching is the PRIMARY signal of cognitive fragmentation.
  ///
  /// Weight calculation:
  /// - Normal app switch: weight 3
  /// - Rapid switch (<10s since last switch): weight 5
  ///
  /// Rapid context switching is the strongest indicator of nervous-system
  /// strain and loss of cognitive continuity.
  void reportAppSwitch() {
    final now = DateTime.now();
    int weight = 3;
    String type = 'app_switch';

    if (_lastAppSwitchTime != null) {
      final gap = now.difference(_lastAppSwitchTime!).inSeconds;

      if (gap < 10) {
        // Rapid context switching - cognitive fragmentation detected
        weight = 5;
        type = 'rapid_switch';
        debugPrint('⚠️ Rapid context switch detected (${gap}s gap)');
      }
    }

    _lastAppSwitchTime = now;
    _lastInteractionTime = now;
    _addEvent(InteractionEvent(timestamp: now, weight: weight, type: type));
  }

  /// Adds an event to the rolling window and checks threshold
  void _addEvent(InteractionEvent event) {
    _pruneExpiredEvents();
    _interactionWindow.addLast(event);
    _checkThreshold();
  }

  /// Manual override to trigger intervention
  void triggerManualIntervention() {
    _isFatigued = true;
    _persistence.incrementOverloadEvents();
    notifyListeners();
  }

  /// Checks if friction score exceeds threshold
  void _checkThreshold() {
    final score = frictionScore;

    if (score > _threshold && !_isFatigued) {
      _isFatigued = true;
      _persistence.incrementOverloadEvents();
      debugPrint(
        '🛑 Cognitive overload detected! Score: $score > Threshold: $_threshold',
      );
    }

    notifyListeners();
  }

  /// Full reset (clears window and fatigue state)
  void reset() {
    _interactionWindow.clear();
    _lastInteractionTime = null;
    _lastAppSwitchTime = null;
    _isFatigued = false;
    notifyListeners();
  }

  /// Soft reset after regulation (clears fatigue but keeps some history)
  void clearFatigue() {
    _isFatigued = false;
    // Clear half the window to give user a fresh start after recovery
    final eventsToKeep = _interactionWindow.length ~/ 2;
    while (_interactionWindow.length > eventsToKeep) {
      _interactionWindow.removeFirst();
    }
    notifyListeners();
  }

  /// Returns a breakdown of current friction sources (for debugging)
  Map<String, int> get frictionBreakdown {
    _pruneExpiredEvents();
    final breakdown = <String, int>{};
    for (final event in _interactionWindow) {
      breakdown[event.type] = (breakdown[event.type] ?? 0) + event.weight;
    }
    return breakdown;
  }
}
