import 'package:mixcine_movie_app/data/models/user_model.dart';
import 'package:mixcine_movie_app/data/datasources/auth_remote_data_source.dart';

class AuthService {
  final AuthRemoteDataSource _dataSource = AuthRemoteDataSource();

  Future<(String, UserModel)> login({
    required String email,
    required String password,
  }) async {
    try {
      final userData = await _dataSource.login(email, password);
      
      // Tạo token dựa trên email để đồng bộ
      final token = 'token_${email.hashCode}';
      
      final user = UserModel(
        id: userData['id'].toString(),
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

  // SỬA LẠI: Dùng email để lấy user mới nhất từ DB
  Future<UserModel?> getUser(String email) async {
    final userData = await _dataSource.getUserByEmail(email);
    if (userData == null) return null;
    return UserModel(
      id: userData['id'].toString(),
      email: userData['email'],
      fullName: userData['full_name'],
      phoneNumber: userData['phone_number'],
      plan: userData['plan'],
    );
  }

  Future<void> updateProfile(UserModel user) async {
    // SỬA LẠI: Dùng email làm khóa cập nhật cho chính xác
    await _dataSource.updateProfile(
      user.email, 
      user.fullName ?? '', 
      user.phoneNumber ?? ''
    );
  }

  Future<void> upgradePlan(String email, String newPlan) async {
    // SỬA LẠI: Dùng email làm khóa nâng cấp
    await _dataSource.updateUserPlan(email, newPlan);
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
