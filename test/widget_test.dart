import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/auth/presentation/auth_landing_page.dart';
import 'package:p2p/features/home/presentation/home_page.dart';

void main() {
  group('Auth UI', () {
    testWidgets('Auth landing page renders buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const AuthLandingPage()),
      );

      expect(
        find.text('Your next car is closer than you think.'),
        findsOneWidget,
      );
      expect(find.text('Login / Create account'), findsOneWidget);
      expect(find.text('Login as Admin'), findsOneWidget);
      expect(find.text('Continue with phone'), findsOneWidget);
    });

    testWidgets('Home page renders showrooms list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const HomePage()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Find your next\ncar in Gujranwala.'), findsOneWidget);
      expect(find.text('Browse cars'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
