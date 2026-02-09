import 'package:flutter/material.dart';

class FatigueProvider with ChangeNotifier {
  int _interactionCount = 0;
  final int _threshold = 40; 
  bool _isFatigued = false;

  int get interactionCount => _interactionCount;
  bool get isFatigued => _isFatigued;

  /// Increments friction based on user interaction (taps/clicks).
  void incrementFriction() {
    _interactionCount++;
    _checkThreshold();
  }

  /// Specialized friction for when a user switches away from the focus app.
  void reportAppSwitch() {
    // App switching is heavily penalized as a sign of distraction
    _interactionCount += 10; 
    _checkThreshold();
  }

  /// Manual override to trigger intervention (e.g., if logic detects compulsive patterns)
  void triggerManualIntervention() {
    _isFatigued = true;
    notifyListeners();
  }

  void _checkThreshold() {
    if (_interactionCount > _threshold) {
      _isFatigued = true;
    }
    notifyListeners();
  }

  void reset() {
    _interactionCount = 0;
    _isFatigued = false;
    notifyListeners();
  }
}
