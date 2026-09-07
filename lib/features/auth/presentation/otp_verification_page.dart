import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../customer/presentation/customer_shell.dart';
import '../domain/auth_repository.dart';
import 'widgets/auth_shell.dart';

/// Verifies a one-time code sent to an email or phone. By default it lands
/// the signed-in user on the home page; pass [onVerified] to branch (e.g. the
/// password reset flow).
class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.method,
    required this.identifier,
    required this.repository,
    this.title = 'Enter your code',
    this.onVerified,
  });

  factory OtpVerificationPage.withMode({
    required AuthMethod method,
    required String identifier,
    required AuthRepository repository,
    required String title,
    required Future<void> Function() onVerified,
  }) {
    return OtpVerificationPage(
      method: method,
      identifier: identifier,
      repository: repository,
      title: title,
      onVerified: onVerified,
    );
  }

  final AuthMethod method;
  final String identifier;
  final AuthRepository repository;
  final String title;
  final Future<void> Function()? onVerified;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  String get _destinationLabel =>
      widget.method == AuthMethod.email ? 'email address' : 'phone number';

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.repository.verifyOtp(
        method: widget.method,
        identifier: widget.identifier,
        token: _codeController.text.trim(),
      );
      if (!mounted) return;
      if (widget.onVerified != null) {
        await widget.onVerified!();
      } else {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const CustomerShell()),
        );
      }
    } on AuthNotConfiguredException {
      _showError('Connect Supabase before signing in.');
    } catch (_) {
      _showError('That code could not be verified. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) setState(() => _errorMessage = message);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: widget.title,
      subtitle: 'We sent a one-time code to your $_destinationLabel.',
      showCar: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check your $_destinationLabel — code sent to ${widget.identifier}.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 8,
              style: const TextStyle(color: Colors.white),
              decoration: authInputDecoration(
                label: 'Verification code',
                icon: Icons.pin_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter the verification code';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFFFFB4A6)),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
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
                    : const Text('Verify and continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
