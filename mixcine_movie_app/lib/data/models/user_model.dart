class UserModel {
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
