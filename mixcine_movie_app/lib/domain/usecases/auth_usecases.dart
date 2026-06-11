import 'package:mixcine_movie_app/core/services/auth_service.dart';

class AuthUseCases {
  final AuthService _authService;

  AuthUseCases(this._authService);

  // Giữ nguyên toàn bộ các hàm cũ (login, register, logout, v.v.) của nhóm bạn ở đây nếu có.
  // Chỉ thay thế hoặc thêm duy nhất hàm updateProfile này:

  Future<String?> updateProfile({
    required String newFullName,
    required String newPhoneNumber,
    List<int>? imageBytes,
    String? fileName,
  }) {
    return _authService.updateProfile(
      newFullName: newFullName,
      newPhoneNumber: newPhoneNumber,
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }
}
