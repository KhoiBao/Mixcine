import '../../database/database_helper.dart';

class AuthRemoteDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 1. HÀM ĐĂNG KÝ
  Future<void> register(String email, String password, String fullName, String phoneNumber) async {
    final db = await _dbHelper.database;
    await db.insert('users', {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'plan': 'FREE', 
    });
  }

  // 2. HÀM ĐĂNG NHẬP
  Future<Map<String, dynamic>> login(String email, String password) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isEmpty) throw Exception('Sai email hoặc mật khẩu!');
    return result.first;
  }

  // 3. CẬP NHẬT GÓI CƯỚC (QUAN TRỌNG: Kiểm tra xem có tìm thấy user không)
  Future<void> updateUserPlan(String email, String newPlan) async {
    final db = await _dbHelper.database;
    final count = await db.update(
      'users',
      {'plan': newPlan},
      where: 'email = ?', 
      whereArgs: [email.trim()], // Trim để tránh lỗi khoảng trắng
    );
    
    if (count > 0) {
      print('✅ [DATABASE] Đã nâng cấp thành công gói $newPlan cho: $email');
    } else {
      print('❌ [DATABASE] KHÔNG tìm thấy user có email: $email để nâng cấp!');
    }
  }

  // 4. LẤY THÔNG TIN USER THEO EMAIL
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // 5. CẬP NHẬT PROFILE
  Future<void> updateProfile(String email, String fullName, String phoneNumber) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      {'full_name': fullName, 'phone_number': phoneNumber},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}
