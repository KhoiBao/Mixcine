import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart' as entity;
import '../../domain/repositories/auth_repository.dart';
import 'dart:typed_data'; // Cần thiết để sử dụng Uint8List
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  @override
  Future<void> login(String id, String name) async {
    // Logic login hiện tại của bạn (giữ nguyên)
  }

  @override
  Future<entity.User?> getCurrentUser() async {
    try {
      final sessionUser = _supabase.auth.currentUser;
      if (sessionUser == null) return null;

      // Đọc dữ liệu từ bảng 'profiles' công khai trên Supabase khi mở app
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', sessionUser.id)
          .maybeSingle();

      if (response == null) {
        // Nếu chưa có profile công khai dưới Database, trả về thông tin email thô
        return UserModel(
              id: sessionUser.id,
              email: sessionUser.email ?? '',
              fullName: '',
              phoneNumber: '',
              avatar: '',
            )
            as entity.User; // Ép kiểu về entity.User để khớp kiểu trả về của hàm
      }

      // Đã sửa tại đây: Sử dụng 'as entity.User' để Dart biết UserModel này chính là một User Entity
      return UserModel.fromJson(response) as entity.User;
    } catch (e) {
      print(
        "Lỗi nạp dữ liệu user khi khởi động app tại AuthRepositoryImpl: $e",
      );
      return null;
    }
  }

  @override
  Future<void> logout() async {
    // Logic logout hiện tại của bạn (giữ nguyên)
  }

  // ĐÃ ĐỒNG BỘ KHỚP KHUÔN MẪU INTERFACE
  @override
  Future<String?> updateProfile({
    required String newFullName, // SỬA TẠI ĐÂY
    required String newPhoneNumber, // SỬA TẠI ĐÂY
    List<int>? imageBytes,
    String? fileName,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("Người dùng chưa đăng nhập hệ thống!");
      }

      String? finalAvatarUrl;

      // 1. XỬ LÝ UPLOAD ẢNH LÊN SUPABASE STORAGE (Giữ nguyên)
      if (imageBytes != null && fileName != null) {
        final fileExtension = fileName.split('.').last;
        final storagePath = '$userId/profile_avatar.$fileExtension';

        await _supabase.storage
            .from('avatars')
            .uploadBinary(
              storagePath,
              Uint8List.fromList(imageBytes),
              fileOptions: const supabase.FileOptions(upsert: true),
            );

        finalAvatarUrl = _supabase.storage
            .from('avatars')
            .getPublicUrl(storagePath);
      }

      // 2. CẬP NHẬT DỮ LIỆU VÀO DATABASE
      final Map<String, dynamic> updateData = {
        'full_name': newFullName, // Dùng trực tiếp tham số chuỗi vừa nhận
        'phone_number': newPhoneNumber, // Dùng trực tiếp tham số chuỗi vừa nhận
      };

      if (finalAvatarUrl != null) {
        updateData['avatar_url'] = finalAvatarUrl;
      }

      await _supabase.from('profiles').update(updateData).eq('id', userId);

      return finalAvatarUrl;
    } catch (e) {
      print("Lỗi nghiêm trọng tại AuthRepositoryImpl.updateProfile: $e");
      rethrow;
    }
  }
}
