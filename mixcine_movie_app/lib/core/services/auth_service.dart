import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mixcine_movie_app/data/models/user_model.dart';
import 'package:mixcine_movie_app/data/datasources/auth_remote_data_source.dart';

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
        id: userData['id'].toString(), // Đây là UUID
        email: userData['email'],
        fullName: userData['full_name'],
        phoneNumber: userData['phone_number'],
        plan: userData['plan'], 
      );
      
      return (token, user);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _dataSource.signInWithGoogle();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _dataSource.resetPassword(email);
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
    if (userData == null) return null;
    return UserModel(
      id: userData['id'].toString(), // Đảm bảo lấy ID (UUID)
      email: userData['email'],
      fullName: userData['full_name'],
      phoneNumber: userData['phone_number'],
      plan: userData['plan'],
    );
  }

  Future<void> updateProfile(UserModel user) async {
    if (user.id == null) {
      throw AuthException('Không tìm thấy ID người dùng để cập nhật');
    }
    // SỬA: Truyền user.id (UUID) và ép kiểu non-nullable
    await _dataSource.updateProfile(
      user.id!,
      user.fullName ?? '', 
      user.phoneNumber ?? ''
    );
  }

  Future<void> upgradePlan(String email, String newPlan) async {
    await _dataSource.updateUserPlan(email, newPlan);
  }

  Future<void> signOut() async {
    await _dataSource.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
