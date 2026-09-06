import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import 'otp_verification_page.dart';

class AuthRequestPage extends StatefulWidget {
  const AuthRequestPage({super.key, required this.method});

  final AuthMethod method;

  @override
  State<AuthRequestPage> createState() => _AuthRequestPageState();
}

class _AuthRequestPageState extends State<AuthRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final AuthRepository _repository = const SupabaseAuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEmail => widget.method == AuthMethod.email;

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final identifier = _identifierController.text.trim();
    try {
      await _repository.requestOtp(
        method: widget.method,
        identifier: identifier,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationPage(
            method: widget.method,
            identifier: identifier,
            repository: _repository,
          ),
        ),
      );
    } on AuthNotConfiguredException {
      _showError('Connect Supabase before requesting a code.');
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('We could not send a code. Check your details and retry.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) setState(() => _errorMessage = message);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEmail
        ? 'What is your email?'
        : 'What is your phone number?';
    final label = _isEmail ? 'Email address' : 'Phone number';

    return Scaffold(
      appBar: AppBar(title: Text(_isEmail ? 'Email sign in' : 'Phone sign in')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We will send you a one-time verification code.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _identifierController,
                      keyboardType: _isEmail
                          ? TextInputType.emailAddress
                          : TextInputType.phone,
                      decoration: InputDecoration(labelText: label),
                      validator: (value) {
                        final input = value?.trim() ?? '';
                        if (input.isEmpty) return 'This field is required';
                        if (_isEmail && !input.contains('@')) {
                          return 'Enter a valid email address';
                        }
                        if (!_isEmail && input.length < 7) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.accentDark),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _requestOtp,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onAccent,
                              ),
                            )
                          : const Text('Send verification code'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
