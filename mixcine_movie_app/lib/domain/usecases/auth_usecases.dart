import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository repository;

  const AuthUseCases(this.repository);

  // Use case 1: Đăng nhập
  Future<void> login(String id, String name) {
    return repository.login(id, name);
  }

  // Use case 2: Lấy User hiện tại
  Future<User?> getCurrentUser() {
    return repository.getCurrentUser();
  }

  // Use case 3: Đăng xuất
  Future<void> logout() {
    return repository.logout();
  }
}
