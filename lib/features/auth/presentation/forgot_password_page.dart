import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import 'otp_verification_page.dart';
import 'reset_password_page.dart';
import 'widgets/auth_shell.dart';

/// Requests a one-time reset code for the given email, then lets the user
/// choose a fresh password in [OtpVerificationPage].
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.repository});

  final AuthRepository? repository;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final AuthRepository _repository =
      widget.repository ?? const SupabaseAuthRepository();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _send() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _repository.requestOtp(method: AuthMethod.email, identifier: email);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationPage.withMode(
            method: AuthMethod.email,
            identifier: email,
            repository: _repository,
            title: 'Verify to reset password',
            onVerified: () async {
              if (!mounted) return;
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => ResetPasswordPage(repository: _repository),
                ),
              );
            },
          ),
        ),
      );
    } on AuthNotConfiguredException {
      setState(() => _error = 'Connect Supabase to continue.');
    } catch (_) {
      setState(() => _error = 'We could not send a code. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Forgot password?',
      subtitle: 'Enter your email and we\'ll send a one-time code.',
      showCar: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: const TextStyle(color: Colors.white),
            decoration: authInputDecoration(
              label: 'Email',
              icon: Icons.mail_outline,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4A6))),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send reset code'),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text('Back to sign in'),
            ),
          ),
        ],
      ),
    );
  }
}
