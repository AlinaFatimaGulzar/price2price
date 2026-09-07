import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../customer/presentation/customer_shell.dart';
import '../domain/auth_repository.dart';
import 'widgets/auth_shell.dart';

/// Sets a brand-new password for the signed-in account (reached after
/// verifying an email reset code).
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.repository});

  final AuthRepository repository;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _submitting = false;
  bool _obscure = true;
  String? _error;

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.repository.updatePassword(newPassword: password);
      if (!mounted) return;
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const CustomerShell()),
        (route) => false,
      );
    } on AuthNotConfiguredException {
      setState(() => _error = 'Connect Supabase to continue.');
    } catch (_) {
      setState(() => _error = 'Could not update your password. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Set a new password',
      subtitle: 'Make it something you\'ll remember.',
      showCar: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            style: const TextStyle(color: Colors.white),
            decoration: authInputDecoration(
              label: 'New password',
              icon: Icons.lock_outline,
              suffixIcon: _visibilityToggle(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _confirmController,
            obscureText: _obscure,
            style: const TextStyle(color: Colors.white),
            decoration: authInputDecoration(
              label: 'Confirm password',
              icon: Icons.lock_outline,
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
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save new password'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visibilityToggle() {
    return IconButton(
      onPressed: () => setState(() => _obscure = !_obscure),
      icon: Icon(
        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.white60,
      ),
      tooltip: _obscure ? 'Show password' : 'Hide password',
    );
  }
}
