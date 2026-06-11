import 'dart:typed_data';
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

      final user = _mapToUserModel(userData);

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
      return _mapToUserModel(userData);
    } catch (e) {
      return null;
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

  // --- HÀM UPDATE PROFILE HOÀN CHỈNH ---
  Future<String?> updateProfile({
    required String newFullName,
    required String newPhoneNumber,
    List<int>? imageBytes,
    String? fileName,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception("Người dùng chưa đăng nhập!");

      String? finalAvatarUrl;

      // 1. Upload ảnh nếu có
      if (imageBytes != null && fileName != null) {
        final fileExtension = fileName.split('.').last;
        final storagePath = '$userId/profile_avatar.$fileExtension';

        await _client.storage
            .from('avatars')
            .uploadBinary(
              storagePath,
              Uint8List.fromList(imageBytes),
              fileOptions: const FileOptions(upsert: true),
            );

        finalAvatarUrl = _client.storage
            .from('avatars')
            .getPublicUrl(storagePath);
      }

      // 2. Cập nhật DB
      await _dataSource.updateProfile(userId, newFullName, newPhoneNumber, finalAvatarUrl);

      // 3. Lấy lại URL ảnh cuối cùng để đồng bộ UI
      if (finalAvatarUrl == null) {
        final userData = await _dataSource.getUserByEmail(_client.auth.currentUser?.email ?? '');
        finalAvatarUrl = userData?['avatar_url'] as String?;
      }

      return finalAvatarUrl;
    } catch (e) {
      print("Lỗi tại AuthService.updateProfile: $e");
      rethrow;
    }
  }

  // Helper để map data từ DB sang UserModel
  UserModel _mapToUserModel(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'].toString(),
      email: data['email'],
      fullName: data['full_name'],
      phoneNumber: data['phone_number'],
      plan: data['plan'] ?? 'FREE',
      avatar: data['avatar_url'] ?? data['avatar'],
    );
  }
}

class AppAuthException implements Exception {
  final String message;
  AppAuthException(this.message);
  @override
  String toString() => message;
}
