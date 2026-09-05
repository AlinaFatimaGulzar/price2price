import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<void> requestOtp({
    required AuthMethod method,
    required String identifier,
  }) async {
    final client = _client;
    if (client == null) throw const AuthNotConfiguredException();

    switch (method) {
      case AuthMethod.email:
        await client.auth.signInWithOtp(
          email: identifier,
          shouldCreateUser: true,
        );
      case AuthMethod.phone:
        await client.auth.signInWithOtp(
          phone: identifier,
          shouldCreateUser: true,
        );
    }
  }

  @override
  Future<void> verifyOtp({
    required AuthMethod method,
    required String identifier,
    required String token,
  }) async {
    final client = _client;
    if (client == null) throw const AuthNotConfiguredException();

    await client.auth.verifyOTP(
      type: method == AuthMethod.email ? OtpType.email : OtpType.sms,
      token: token,
      email: method == AuthMethod.email ? identifier : null,
      phone: method == AuthMethod.phone ? identifier : null,
    );
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final client = _client;
    if (client == null) throw const AuthNotConfiguredException();

    final response = await client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {'full_name': fullName?.trim()},
    );

    if (response.user != null && response.session == null) {
      // The Supabase project confirms emails before issuing a session.
      throw const AuthEmailConfirmationRequiredException();
    }
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) throw const AuthNotConfiguredException();

    try {
      await client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on AuthException {
      throw const AuthInvalidCredentialsException();
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    final client = _client;
    if (client == null) throw const AuthNotConfiguredException();

    await client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
