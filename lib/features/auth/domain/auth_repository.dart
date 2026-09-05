enum AuthMethod { email, phone }

abstract interface class AuthRepository {
  Future<void> requestOtp({
    required AuthMethod method,
    required String identifier,
  });

  Future<void> verifyOtp({
    required AuthMethod method,
    required String identifier,
    required String token,
  });

  /// Creates a new email + password account. Returns normally on success.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  });

  /// Signs in an existing email + password account.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sets a new password for the signed-in account.
  Future<void> updatePassword({required String newPassword});
}

class AuthNotConfiguredException implements Exception {
  const AuthNotConfiguredException();

  @override
  String toString() => 'Supabase is not configured for this build.';
}

class AuthInvalidCredentialsException implements Exception {
  const AuthInvalidCredentialsException();

  @override
  String toString() =>
      'The email or password is incorrect. Double-check and try again.';
}

class AuthEmailConfirmationRequiredException implements Exception {
  const AuthEmailConfirmationRequiredException();

  @override
  String toString() =>
      'Account created. Check your inbox to confirm your email before signing in.';
}
