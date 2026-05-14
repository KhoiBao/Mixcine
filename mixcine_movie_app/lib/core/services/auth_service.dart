import 'dart:async';

/// A minimal mock auth service. Replace with real network calls in production.
class AuthService {
  // Simulate network delay
  final Duration _delay = const Duration(milliseconds: 700);

  /// Mock login. Accepts any email that contains '@' and password length >= 6.
  /// Returns a mock token on success.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(_delay);

    if (!email.contains('@') || password.length < 6) {
      throw AuthException('Invalid credentials');
    }

    // Return a fake token; in real app obtain from backend
    return 'mock_token_${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Mock register. Basic checks.
  Future<String> register({
    required String email,
    required String password,
  }) async {
    await Future.delayed(_delay);

    if (!email.contains('@')) {
      throw AuthException('Invalid email');
    }

    if (password.length < 6) {
      throw AuthException('Password too short (min 6 chars)');
    }

    // In real app, might return token or require email verification
    return 'mock_token_${email.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
