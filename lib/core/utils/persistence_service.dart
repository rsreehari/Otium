import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const String keyUserType = 'user_type';
  static const String keyInteractionCount = 'interaction_count';
  static const String keyOverloadEvents = 'overload_events';
  static const String keyLastSprint = 'last_sprint_timestamp';

  final SharedPreferences _prefs;

  PersistenceService(this._prefs);

  static Future<PersistenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PersistenceService(prefs);
  }

  // User details
  String? get userType => _prefs.getString(keyUserType);
  Future<void> setUserType(String type) => _prefs.setString(keyUserType, type);

  // Interaction tracking (cross-session)
  int get dailyInteractionCount => _prefs.getInt(keyInteractionCount) ?? 0;
  Future<void> setDailyInteractionCount(int count) => _prefs.setInt(keyInteractionCount, count);

  // Overload events
  int get overloadEventsCount => _prefs.getInt(keyOverloadEvents) ?? 0;
  Future<void> incrementOverloadEvents() {
    final current = overloadEventsCount;
    return _prefs.setInt(keyOverloadEvents, current + 1);
  }

  // Sprint tracking
  String? get lastSprintTimestamp => _prefs.getString(keyLastSprint);
  Future<void> setLastSprintTimestamp(String timestamp) => _prefs.setString(keyLastSprint, timestamp);
}
