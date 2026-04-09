import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences() : _prefs = SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  Future<bool> hasSeenOnboarding() async {
    return await _prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(_hasSeenOnboardingKey, value);
  }
}
