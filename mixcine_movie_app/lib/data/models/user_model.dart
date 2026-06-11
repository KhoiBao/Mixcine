class UserModel {
  final String? id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatar;
  final String? plan;

  const UserModel({
    this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatar,
    this.plan,
  });

  // ... hàm copyWith giữ nguyên ...

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      // ĐỒNG BỘ TẠI ĐÂY: Gửi lên đúng tên cột 'avatar_url' trên Database
      'avatar_url': avatar,
      'plan': plan,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number']?.toString(),
      // ĐỒNG BỘ TẠI ĐÂY: Đọc từ trường 'avatar_url' hoặc 'avatar' đề phòng nhóm dùng cả hai
      avatar: (json['avatar_url'] ?? json['avatar']) as String?,
      plan: json['plan'] as String?,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, avatar: $avatar, plan: $plan)';
  }
}
