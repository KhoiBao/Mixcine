import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    _listenToAuthChanges();
    _load();
    return const AuthState();
  }

  AppPreferences get _prefs => ref.read(appPreferencesProvider);
  AuthService get _service => ref.read(authServiceProvider);

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final event = data.event;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // Ưu tiên lấy user từ Auth metadata ngay lập tức để không bị null
        final fallbackUser = UserModel(
          id: session.user.id,
          email: session.user.email ?? '',
          fullName: session.user.userMetadata?['full_name'] ?? session.user.userMetadata?['name'] ?? 'Người dùng',
          plan: 'FREE',
        );

        state = AuthState(token: session.accessToken, user: fallbackUser, isLoading: false);
        await _prefs.setAuthToken(session.accessToken);
        await _prefs.setUserData(fallbackUser);

        // Sau đó mới thử cập nhật từ Profile DB (nếu có)
        try {
          final dbUser = await _service.getUser(session.user.email!);
          if (dbUser != null) {
            state = state.copyWith(user: dbUser);
            await _prefs.setUserData(dbUser);
          }
        } catch (_) {}
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AuthState();
      }
    });
  }

  Future<void> _load() async {
    final token = await _prefs.getAuthToken();
    final user = await _prefs.getUserData();
    if (user != null && user.id != null) {
      if (user.id!.length < 30 || user.id!.contains('@')) {
        await logout();
        return;
      }
    }
    state = AuthState(token: token, user: user);
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final (token, user) = await _service.login(email: email, password: password);
      await _prefs.setAuthToken(token);
      await _prefs.setUserData(user);
      state = AuthState(token: token, user: user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String email, String password, String fullName, String phoneNumber) async {
    state = const AuthState(isLoading: true);
    try {
      final (token, user) = await _service.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      await _prefs.setAuthToken(token);
      await _prefs.setUserData(user);
      state = AuthState(token: token, user: user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.signInWithGoogle();
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _service.signOut();
    await _prefs.setAuthToken(null);
    await _prefs.setUserData(null);
    state = const AuthState();
  }

  Future<void> resetPassword(String email) async {
    await _service.resetPassword(email);
  }

  Future<void> reloadUserFromDb() async {
    final currentUser = state.user;
    if (currentUser == null) return;
    final updatedUser = await _service.getUser(currentUser.email);
    if (updatedUser != null) {
      await _prefs.setUserData(updatedUser);
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.updateProfile(updatedUser);
      await _prefs.setUserData(updatedUser);
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
