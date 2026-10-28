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

  static const String _keySavedUserPhone = 'alnur_saved_user_phone';
  static const String _keyIsGuest = 'alnur_is_guest';

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

  /// Saves the user's phone number.
  static Future<void> saveUserPhone(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedUserPhone, phone);
    } catch (_) {}
  }

  /// Retrieves the saved user phone if previously stored.
  static Future<String?> getSavedUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySavedUserPhone);
    } catch (_) {
      return null;
    }
  }

  /// Sets whether the app is currently browsing in guest mode.
  static Future<void> setGuestMode(bool isGuest) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsGuest, isGuest);
    } catch (_) {}
  }

  /// Returns true if the user is in guest mode. Defaults to true if no saved credentials exist.
  static Future<bool> isGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsGuest) ?? false;
    } catch (_) {
      return false;
    }
  }

  static const String _keySavedUserAvatar = 'alnur_saved_user_avatar';
  static const String _keySavedUserBio = 'alnur_saved_user_bio';
  static const String _keySavedUserCurrency = 'alnur_saved_user_currency';
  static const String _keyCachedAddresses = 'alnur_cached_addresses_json';

  /// Saves the user's avatar URL.
  static Future<void> saveUserAvatar(String avatarUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedUserAvatar, avatarUrl);
    } catch (_) {}
  }

  /// Retrieves the saved avatar URL.
  static Future<String?> getSavedUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySavedUserAvatar);
    } catch (_) {
      return null;
    }
  }

  /// Saves the user's bio.
  static Future<void> saveUserBio(String bio) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedUserBio, bio);
    } catch (_) {}
  }

  /// Retrieves the saved bio.
  static Future<String?> getSavedUserBio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySavedUserBio);
    } catch (_) {
      return null;
    }
  }

  /// Saves the preferred currency code (e.g. NGN, USD, GBP, SAR).
  static Future<void> saveUserCurrency(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedUserCurrency, currency);
    } catch (_) {}
  }

  /// Retrieves the preferred currency code.
  static Future<String?> getSavedUserCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySavedUserCurrency);
    } catch (_) {
      return null;
    }
  }

  /// Saves serialized address list for offline resilience.
  static Future<void> saveCachedAddresses(String jsonStr) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCachedAddresses, jsonStr);
    } catch (_) {}
  }

  /// Retrieves serialized cached addresses.
  static Future<String?> getCachedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyCachedAddresses);
    } catch (_) {
      return null;
    }
  }

  /// Clears user credentials and marks as guest on logout.
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySavedUserName);
      await prefs.remove(_keySavedUserEmail);
      await prefs.remove(_keySavedUserPhone);
      await prefs.remove(_keySavedUserAvatar);
      await prefs.remove(_keySavedUserBio);
      await prefs.remove(_keySavedUserCurrency);
      await prefs.remove(_keyCachedAddresses);
      await prefs.setBool(_keyIsGuest, true);
    } catch (_) {}
  }

  /// Clears onboarding preferences to allow re-testing first-time flow.
  static Future<void> resetForFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHasCompletedOnboarding);
      await prefs.remove(_keySavedUserName);
      await prefs.remove(_keySavedUserEmail);
      await prefs.remove(_keySavedUserPhone);
      await prefs.remove(_keySavedUserAvatar);
      await prefs.remove(_keySavedUserBio);
      await prefs.remove(_keySavedUserCurrency);
      await prefs.remove(_keyCachedAddresses);
      await prefs.remove(_keyIsGuest);
    } catch (_) {}
  }
}
