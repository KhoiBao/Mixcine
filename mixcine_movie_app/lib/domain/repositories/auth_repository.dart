import '../entities/user.dart';

abstract class AuthRepository {
  /// Lưu thông tin người dùng khi đăng nhập thành công
  Future<void> login(String id, String name);

  /// Lấy thông tin người dùng hiện tại đang đăng nhập
  Future<User?> getCurrentUser();

  /// Xóa phiên đăng nhập
  Future<void> logout();
}
