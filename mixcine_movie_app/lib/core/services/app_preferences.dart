import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mixcine_movie_app/data/models/user_model.dart';

class AppPreferences {
  AppPreferences() : _prefs = SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  Future<bool> hasSeenOnboarding() async {
    return await _prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(_hasSeenOnboardingKey, value);
  }

  Future<String?> getAuthToken() async {
    return await _prefs.getString(_authTokenKey);
  }

  Future<void> setAuthToken(String? token) async {
    if (token == null) {
      await _prefs.remove(_authTokenKey);
    } else {
      await _prefs.setString(_authTokenKey, token);
    }
  }

  Future<UserModel?> getUserData() async {
    final jsonString = await _prefs.getString(_userDataKey);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> setUserData(UserModel? user) async {
    if (user == null) {
      await _prefs.remove(_userDataKey);
    } else {
      await _prefs.setString(_userDataKey, jsonEncode(user.toJson()));
    }
  }
}
