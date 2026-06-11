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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar': avatar,
      'plan': plan,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      // SỬA: Ép kiểu an toàn, tránh lỗi nếu DB trả về int
      phoneNumber: json['phone_number']?.toString(),
      avatar: json['avatar'] as String?,
      plan: json['plan'] as String?,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, plan: $plan)';
  }
}
