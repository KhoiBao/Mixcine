class UserModel {
  final String? id; // Đây là UUID từ Supabase
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatar;
  final String? plan; // Lưu gói cước: FREE, VIP, VIP_PRO

  const UserModel({
    this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatar,
    this.plan,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatar,
    String? plan,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      plan: plan ?? this.plan,
    );
  }

  // Chuyển sang Map để đẩy lên Supabase (phải khớp tên cột trong DB)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName, // Khớp cột full_name
      'phone_number': phoneNumber, // Khớp cột phone_number
      'avatar': avatar,
      'plan': plan, // Khớp cột plan
    };
  }

  // Khởi tạo từ JSON trả về của Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number']?.toString(),
      avatar: json['avatar'] as String?,
      plan: json['plan'] as String? ?? 'FREE', // Mặc định là FREE nếu null
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, plan: $plan)';
  }
}
