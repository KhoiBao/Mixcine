import 'package:mixcine_movie_app/data/models/user_model.dart';

/// A minimal mock auth service. Replace with real network calls in production.
class AuthService {
  // Simulate network delay
  final Duration _delay = const Duration(milliseconds: 700);

  /// Mock login. Accepts any email that contains '@' and password length >= 6.
  /// Returns a tuple of (token, user) on success.
  Future<(String, UserModel)> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(_delay);

    if (!email.contains('@') || password.length < 6) {
      throw AuthException('Invalid credentials');
    }

    // Return a fake token and user model
    final token =
        'mock_token_${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(email: email);
    return (token, user);
  }

  /// Mock register. Basic checks.
  Future<(String, UserModel)> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    await Future.delayed(_delay);

    if (!email.contains('@')) {
      throw AuthException('Invalid email');
    }

    if (password.length < 6) {
      throw AuthException('Password too short (min 6 chars)');
    }

    if (fullName.trim().isEmpty) {
      throw AuthException('Full name cannot be empty');
    }

    if (phoneNumber.trim().isEmpty) {
      throw AuthException('Phone number cannot be empty');
    }

    // Return a fake token and user model
    final token =
        'mock_token_${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    return (token, user);
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
