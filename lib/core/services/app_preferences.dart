import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences() : _prefs = SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  /// Key lưu trạng thái Dark Mode.
  static const String _isDarkModeKey = 'is_dark_mode';

  Future<bool> hasSeenOnboarding() async {
    return await _prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(_hasSeenOnboardingKey, value);
  }

  /// Đọc trạng thái Dark Mode đã lưu. Mặc định là true (Dark).
  Future<bool> isDarkMode() async {
    return await _prefs.getBool(_isDarkModeKey) ?? true;
  }

  /// Lưu trạng thái Dark Mode vào bộ nhớ cục bộ.
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_isDarkModeKey, value);
  }
}

