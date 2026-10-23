import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPreferences {
  static const String _keyHasCompletedOnboarding = 'alnur_has_completed_onboarding';
  static const String _keySavedUserName = 'alnur_saved_user_name';
  static const String _keySavedUserEmail = 'alnur_saved_user_email';
  static const String _keyFirstOpenTimestamp = 'alnur_first_open_timestamp';
  static const String _keyLastVisitTimestamp = 'alnur_last_visit_timestamp';

  /// Returns true if the user has previously completed the onboarding flow.
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasCompletedOnboarding) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Sets whether onboarding has been completed.
  static Future<void> setOnboardingCompleted({bool completed = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasCompletedOnboarding, completed);
      await prefs.setInt(_keyLastVisitTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Records the very first app launch if not recorded yet.
  static Future<void> recordFirstLaunchIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_keyFirstOpenTimestamp)) {
        await prefs.setInt(_keyFirstOpenTimestamp, DateTime.now().millisecondsSinceEpoch);
      }
      await prefs.setInt(_keyLastVisitTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Saves the active or returning user's name for personalized greetings.
  static Future<void> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedUserName, name);
    } catch (_) {}
  }

  /// Retrieves the saved user name if previously stored.
  static Future<String?> getSavedUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySavedUserName);
    } catch (_) {
      return null;
    }
  }

  /// Saves the active or returning user's email address.
  static Future<void> saveUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedUserEmail, email);
    } catch (_) {}
  }

  /// Retrieves the saved user email if previously stored.
  static Future<String?> getSavedUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySavedUserEmail);
    } catch (_) {
      return null;
    }
  }

  /// Clears onboarding preferences to allow re-testing first-time flow.
  static Future<void> resetForFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHasCompletedOnboarding);
      await prefs.remove(_keySavedUserName);
      await prefs.remove(_keySavedUserEmail);
    } catch (_) {}
  }
}
