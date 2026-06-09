import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Đăng nhập bằng Email/Password
  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Lấy User hiện tại (Firebase đã tự động lưu dưới máy nên gọi hàm này rất nhanh)
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Đăng xuất
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
