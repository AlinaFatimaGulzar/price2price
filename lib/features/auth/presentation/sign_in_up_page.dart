import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../home/presentation/home_page.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import 'auth_request_page.dart';
import 'forgot_password_page.dart';
import 'widgets/auth_shell.dart';

/// Customer sign in / create account. A single glass card that slides
/// between the two modes, keeping the flow short and tempting.
class SignInUpPage extends StatefulWidget {
  const SignInUpPage({super.key, this.repository});

  final AuthRepository? repository;

  @override
  State<SignInUpPage> createState() => _SignInUpPageState();
}

class _SignInUpPageState extends State<SignInUpPage> {
  late final AuthRepository _repository =
      widget.repository ?? const SupabaseAuthRepository();

  bool _signUp = false;
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _success;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _switchMode(bool signUp) {
    setState(() {
      _signUp = signUp;
      _error = null;
      _success = null;
    });
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    if (_signUp) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _error = 'Please tell us your name');
        return;
      }
      if (password != _confirmController.text) {
        setState(() => _error = 'Passwords do not match');
        return;
      }
    }

    setState(() {
      _submitting = true;
      _error = null;
      _success = null;
    });

    try {
      if (_signUp) {
        try {
          await _repository.signUpWithEmail(
            email: email,
            password: password,
            fullName: _nameController.text.trim(),
          );
        } on AuthEmailConfirmationRequiredException catch (e) {
          if (mounted) setState(() => _success = e.toString());
          return;
        }
      } else {
        await _repository.signInWithEmail(email: email, password: password);
      }
      if (!mounted) return;
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on AuthInvalidCredentialsException catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } on AuthNotConfiguredException {
      if (mounted) setState(() => _error = 'Connect Supabase to continue.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: _signUp ? 'Create your account' : 'Welcome back',
      subtitle: _signUp
          ? 'Join the local car community and start exploring.'
          : 'You\'ll stay signed in until you log out.',
      showCar: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ModeToggle(signUp: _signUp, onChanged: _switchMode),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _signUp ? _buildSignUpFields() : _buildSignInFields(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.danger,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_success != null) ...[
            const SizedBox(height: 14),
            _SuccessNotice(message: _success!),
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
                  : Text(_signUp ? 'Create account' : 'Sign in'),
            ),
          ),
          if (!_signUp) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ForgotPasswordPage(),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFD9C4),
                ),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 6),
            _Divider(),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const AuthRequestPage(method: AuthMethod.email),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Continue with a one-time code'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignInFields() {
    return Column(
      key: const ValueKey('signin'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_emailField(), const SizedBox(height: 14), _passwordField()],
    );
  }

  Widget _buildSignUpFields() {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: authInputDecoration(
            label: 'Full name',
            icon: Icons.person_outline,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 14),
        _emailField(),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: authInputDecoration(
            label: 'Password',
            icon: Icons.lock_outline,
            suffixIcon: _visibilityToggle(() {
              setState(() => _obscurePassword = !_obscurePassword);
            }, _obscurePassword),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          style: const TextStyle(color: Colors.white),
          decoration: authInputDecoration(
            label: 'Confirm password',
            icon: Icons.lock_outline,
            suffixIcon: _visibilityToggle(() {
              setState(() => _obscureConfirm = !_obscureConfirm);
            }, _obscureConfirm),
          ),
        ),
      ],
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      decoration: authInputDecoration(label: 'Email', icon: Icons.mail_outline),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: authInputDecoration(
        label: 'Password',
        icon: Icons.lock_outline,
        suffixIcon: _visibilityToggle(() {
          setState(() => _obscurePassword = !_obscurePassword);
        }, _obscurePassword),
      ),
    );
  }

  Widget _visibilityToggle(VoidCallback onPressed, bool obscure) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.white60,
      ),
      tooltip: obscure ? 'Show password' : 'Hide password',
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.signUp, required this.onChanged});

  final bool signUp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _segBtn('Sign in', !signUp, () => onChanged(false))),
          Expanded(
            child: _segBtn('Create account', signUp, () => onChanged(true)),
          ),
        ],
      ),
    );
  }

  Widget _segBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.18))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.18))),
      ],
    );
  }
}

class _SuccessNotice extends StatelessWidget {
  const _SuccessNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2B1E).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2E7D5B).withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFF7ED9B0),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF7ED9B0)),
            ),
          ),
        ],
      ),
    );
  }
}
