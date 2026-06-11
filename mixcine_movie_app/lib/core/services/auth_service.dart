import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mixcine_movie_app/data/models/user_model.dart';
import 'package:mixcine_movie_app/data/datasources/auth_remote_data_source.dart';
import 'package:mixcine_movie_app/data/datasources/subscription_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final AuthRemoteDataSource _dataSource = AuthRemoteDataSource();
  final _client = Supabase.instance.client;

  Future<(String, UserModel)> login({
    required String email,
    required String password,
  }) async {
    try {
      final userData = await _dataSource.login(email, password);
      final token = _client.auth.currentSession?.accessToken ?? '';

      final user = UserModel(
        id: userData['id'].toString(),
        email: userData['email'],
        fullName: userData['full_name'],
        phoneNumber: userData['phone_number'],
        plan: userData['plan'],
      );

      return (token, user);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<(String, UserModel)> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      await _dataSource.register(email, password, fullName, phoneNumber);
      return await login(email: email, password: password);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _dataSource.signInWithGoogle();
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _dataSource.resetPassword(email);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<UserModel?> getUser(String email) async {
    try {
      final userData = await _dataSource.getUserByEmail(email);
      if (userData == null) return null;
      return UserModel(
        id: userData['id'].toString(),
        email: userData['email'],
        fullName: userData['full_name'],
        phoneNumber: userData['phone_number'],
        plan: userData['plan'],
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(UserModel user) async {
    if (user.id == null) {
      throw AppAuthException('Không tìm thấy ID người dùng để cập nhật');
    }
    try {
      await _dataSource.updateProfile(
        user.id!,
        user.fullName ?? '',
        user.phoneNumber ?? ''
      );
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> upgradePlan(String userId, String newPlan) async {
    try {
      await _dataSource.updateUserPlan(userId, newPlan);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    final userId = _client.auth.currentUser?.id;
    await _client.auth.signOut();

    // Xóa data local của user vừa logout
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      final localDS = SubscriptionLocalDataSource(prefs);
      await localDS.clearSubscription(userId);
    }
  }
}

class AppAuthException implements Exception {
  final String message;
  AppAuthException(this.message);
  @override
  String toString() => message;
}
