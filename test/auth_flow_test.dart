import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/auth/domain/auth_repository.dart';
import 'package:p2p/features/auth/presentation/otp_verification_page.dart';
import 'package:p2p/features/auth/presentation/sign_in_up_page.dart';

class _FakeAuthRepository implements AuthRepository {
  final List<String> createdEmails = [];
  final List<String> signedInEmails = [];
  final List<String> verified = [];
  String updatePasswordValue = '';
  int updatePasswordCalls = 0;

  bool signInFails = false;
  bool confirmEmailRequired = false;

  @override
  Future<void> requestOtp({
    required AuthMethod method,
    required String identifier,
  }) async {}

  @override
  Future<void> verifyOtp({
    required AuthMethod method,
    required String identifier,
    required String token,
  }) async {
    verified.add(identifier);
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    createdEmails.add(email);
    if (confirmEmailRequired) {
      throw const AuthEmailConfirmationRequiredException();
    }
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (signInFails) throw const AuthInvalidCredentialsException();
    signedInEmails.add(email);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    updatePasswordValue = newPassword;
    updatePasswordCalls += 1;
  }
}

void tallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(600, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('Sign in / Sign up', () {
    testWidgets('sign in submits email and password', (tester) async {
      tallViewport(tester);
      final repo = _FakeAuthRepository();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: SignInUpPage(repository: repo),
        ),
      );
      // FadeInY is time-based; drive a few frames so fields are visible.
      await tester.pump(const Duration(milliseconds: 700));

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'buyer@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'secret123',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign in'),
        ),
      );
      await tester.pump();

      expect(repo.signedInEmails, ['buyer@example.com']);
    });

    testWidgets('sign up validates matching passwords and submits', (
      tester,
    ) async {
      tallViewport(tester);
      final repo = _FakeAuthRepository();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: SignInUpPage(repository: repo),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));

      await tester.tap(find.text('Create account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Full name'),
        'Ayesha Khan',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'ayesha@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'secret123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm password'),
        'secret123',
      );
      await tester.tap(find.text('Create account').last);
      await tester.pump();

      expect(repo.createdEmails, ['ayesha@example.com']);
    });

    testWidgets('sign up shows confirm-email notice when session is pending', (
      tester,
    ) async {
      tallViewport(tester);
      final repo = _FakeAuthRepository()..confirmEmailRequired = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: SignInUpPage(repository: repo),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));

      await tester.tap(find.text('Create account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, 'Full name'),
        'Ayesha Khan',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'ayesha@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'secret123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm password'),
        'secret123',
      );
      await tester.tap(find.text('Create account').last);
      await tester.pump();

      expect(find.textContaining('Check your inbox'), findsOneWidget);
      expect(repo.createdEmails, ['ayesha@example.com']);
    });

    testWidgets('sign in surfaces invalid credentials message', (tester) async {
      tallViewport(tester);
      final repo = _FakeAuthRepository()..signInFails = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: SignInUpPage(repository: repo),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'buyer@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'wrongpass',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign in'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('email or password is incorrect'),
        findsOneWidget,
      );
    });

    testWidgets('otp page branches to custom onVerified flow', (tester) async {
      tallViewport(tester);
      final repo = _FakeAuthRepository();
      var branched = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: OtpVerificationPage.withMode(
            method: AuthMethod.email,
            identifier: 'buyer@example.com',
            repository: repo,
            title: 'Reset password',
            onVerified: () async {
              branched = true;
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));

      await tester.enterText(
        find.widgetWithText(TextField, 'Verification code'),
        '123456',
      );
      await tester.tap(find.text('Verify and continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(repo.verified, ['buyer@example.com']);
      expect(branched, isTrue);
    });
  });
}
