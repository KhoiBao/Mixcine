import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/app_preferences.dart';
import 'app_providers.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthState {
  const AuthState({this.token, this.isLoading = false, this.error});

  final String? token;
  final bool isLoading;
  final String? error;

  AuthState copyWith({String? token, bool? isLoading, String? error}) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // initial state; then load persisted token
    _load();
    return const AuthState();
  }

  AppPreferences get _prefs => ref.read(appPreferencesProvider);
  AuthService get _service => ref.read(authServiceProvider);

  Future<void> _load() async {
    final token = await _prefs.getAuthToken();
    state = state.copyWith(token: token);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _service.login(email: email, password: password);
      await _prefs.setAuthToken(token);
      state = state.copyWith(token: token, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _service.register(email: email, password: password);
      await _prefs.setAuthToken(token);
      state = state.copyWith(token: token, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _prefs.setAuthToken(null);
    state = const AuthState(token: null);
  }
}
