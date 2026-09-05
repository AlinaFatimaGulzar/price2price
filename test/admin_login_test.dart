import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/admin/domain/admin_auth_repository.dart';
import 'package:p2p/features/admin/presentation/admin_login_page.dart';

class _FakeAdminAuthRepository implements AdminAuthRepository {
  bool signInCalled = false;
  final bool success;

  _FakeAdminAuthRepository({this.success = true});

  @override
  Future<void> signInAdmin({
    required String email,
    required String password,
  }) async {
    signInCalled = true;
    if (!success) throw Exception('This account does not have admin access');
  }

  @override
  Future<bool> isCurrentUserAdmin() async => success;

  @override
  Future<void> signOutAdmin() async {}

  @override
  Future<String?> getCurrentAdminId() async => null;
}

void main() {
  group('Admin Login', () {
    Future<_FakeAdminAuthRepository> pumpLogin(
      WidgetTester tester, {
      bool success = true,
    }) async {
      final fake = _FakeAdminAuthRepository(success: success);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AdminLoginPage(repository: fake),
        ),
      );
      return fake;
    }

    testWidgets('calls signInAdmin with email and password', (tester) async {
      final fake = await pumpLogin(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Admin Email'),
        'admin@p2p.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(fake.signInCalled, isTrue);
    });

    testWidgets('shows error when credentials rejected', (tester) async {
      await pumpLogin(tester, success: false);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Admin Email'),
        'admin@p2p.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('admin access'), findsOneWidget);
    });

    testWidgets('shows validation message when fields empty', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Please fill all fields'), findsOneWidget);
    });
  });
}
