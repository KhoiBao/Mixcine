class User {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber; // 👈 THÊM DÒNG NÀY VÀO ENTITY ĐỂ HẾT LỖI
  final String? avatar;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber, // 👈 THÊM VÀO CONSTRUCTOR
    this.avatar,
  });
}
