import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthRemoteDataSource {
  final _client = Supabase.instance.client;

  // 1. ĐĂNG KÝ
  Future<void> register(String email, String password, String fullName, String phoneNumber) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phoneNumber,
      },
    );
  }

  // 2. ĐĂNG NHẬP
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) throw Exception('Đăng nhập thất bại');

    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', response.user!.id)
        .maybeSingle();

    return profile ?? _createFallbackProfile(response.user!);
  }

  // 3. ĐĂNG NHẬP GOOGLE
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.movieapp://callback',
    );
  }

  Map<String, dynamic> _createFallbackProfile(User user) {
    return {
      'id': user.id,
      'email': user.email,
      'full_name': user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Người dùng',
      'phone_number': user.userMetadata?['phone_number'] ?? '',
      'plan': 'FREE',
    };
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final profile = await _client
        .from('profiles')
        .select()
        .eq('email', email.trim())
        .maybeSingle();

    if (profile == null) {
      final currentUser = _client.auth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        return _createFallbackProfile(currentUser);
      }
    }
    return profile;
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: kIsWeb ? null : 'io.supabase.movieapp://callback',
    );
  }

  // 🚀 ĐÃ SỬA CHUẨN XÁC: Gọi update xong mới gọi .select() để bắt lỗi RLS
  Future<void> updateUserPlan(String userId, String newPlan) async {
    final response = await _client
        .from('profiles')
        .update({'plan': newPlan})
        .eq('id', userId)
        .select();

    print('KẾT QUẢ UPDATE VIP TỪ SUPABASE: $response');
  }

  Future<void> updateProfile(String userId, String fullName, String phoneNumber) async {
    await _client
        .from('profiles')
        .update({
      'full_name': fullName,
      'phone_number': phoneNumber,
    })
        .eq('id', userId);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}