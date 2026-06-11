import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mixcine_movie_app/data/models/user_model.dart';
import 'package:mixcine_movie_app/data/datasources/auth_remote_data_source.dart';

class AuthService {
  final AuthRemoteDataSource _dataSource = AuthRemoteDataSource();
  final _client = Supabase.instance.client;

  // --- CÁC HÀM KHÁC GIỮ NGUYÊN ---
  Future<(String, UserModel)> login({
    required String email,
    required String password,
  }) async {
    try {
      final userData = await _dataSource.login(email, password);
      final token = _client.auth.currentSession?.accessToken ?? '';
      return (token, _mapToUserModel(userData));
    } catch (e) {
      throw AuthException(e.toString());
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
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<UserModel?> getUser(String email) async {
    final userData = await _dataSource.getUserByEmail(email);
    return userData != null ? _mapToUserModel(userData) : null;
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
      final Map<String, dynamic> updateData = {
        'full_name': newFullName,
        'phone_number': newPhoneNumber,
      };

      if (finalAvatarUrl != null) {
        updateData['avatar_url'] = finalAvatarUrl;
      }

      await _client.from('profiles').update(updateData).eq('id', userId);

      // 3. Lấy lại URL ảnh cuối cùng để đồng bộ UI
      if (finalAvatarUrl == null) {
        final profileRes = await _client
            .from('profiles')
            .select('avatar_url')
            .eq('id', userId)
            .maybeSingle();
        finalAvatarUrl = profileRes?['avatar_url'] as String?;
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
      plan: data['plan'],
      avatar: data['avatar_url'] ?? data['avatar'],
    );
  }

  // --- MỞ RỘNG CÁC HÀM KHÁC ---
  Future<void> signInWithGoogle() async => await _dataSource.signInWithGoogle();
  Future<void> signOut() async => await _client.auth.signOut();
  Future<void> resetPassword(String email) async =>
      await _dataSource.resetPassword(email);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
