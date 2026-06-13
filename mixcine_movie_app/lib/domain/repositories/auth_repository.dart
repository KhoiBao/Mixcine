import '../entities/user.dart';

abstract class AuthRepository {
  // Các usecase cũ của dự án
  Future<void> login(String id, String name);
  Future<User?> getCurrentUser();
  Future<void> logout();

  Future<String?> updateProfile({
    required String newFullName,
    required String newPhoneNumber,
    List<int>? imageBytes,
    String? fileName,
  });
}
