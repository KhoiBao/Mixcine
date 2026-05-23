class UserModel {
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatar;

  UserModel({
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatar,
  });

  UserModel copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatar,
  }) {
    return UserModel(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatar: json['avatar'] as String?,
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  final int id;
  final String username;
  final String email;
  final String password;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
    );
  }
}
