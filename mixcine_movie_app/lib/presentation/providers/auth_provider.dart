import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixcine_movie_app/data/models/user_model.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/app_preferences.dart';
import 'app_providers.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthState {
  const AuthState({this.token, this.user, this.isLoading = false, this.error});

  final String? token;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    String? token,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // initial state; then load persisted token and user
    _load();
    return const AuthState();
  }

  AppPreferences get _prefs => ref.read(appPreferencesProvider);
  AuthService get _service => ref.read(authServiceProvider);

  Future<void> _load() async {
    final token = await _prefs.getAuthToken();
    final user = await _prefs.getUserData();
    state = state.copyWith(token: token, user: user);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final (token, user) = await _service.login(
        email: email,
        password: password,
      );
      await _prefs.setAuthToken(token);
      await _prefs.setUserData(user);
      state = state.copyWith(token: token, user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(
    String email,
    String password,
    String fullName,
    String phoneNumber,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final (token, user) = await _service.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      await _prefs.setAuthToken(token);
      await _prefs.setUserData(user);
      state = state.copyWith(token: token, user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _prefs.setAuthToken(null);
    await _prefs.setUserData(null);
    state = const AuthState(token: null, user: null);
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    await _prefs.setUserData(updatedUser);
    state = state.copyWith(user: updatedUser);
  }
}
