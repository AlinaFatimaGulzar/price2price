import 'package:flutter/material.dart';

import '../features/auth/data/session_repository.dart';
import '../features/auth/presentation/auth_landing_page.dart';
import '../features/customer/presentation/customer_shell.dart';
import '../features/admin/presentation/admin_mode_gateway_page.dart';
import '../features/admin/presentation/admin_login_page.dart';
import '../features/splash/presentation/splash_page.dart';
import 'theme/app_theme.dart';

class P2PApp extends StatefulWidget {
  const P2PApp({super.key});

  @override
  State<P2PApp> createState() => _P2PAppState();
}

class _P2PAppState extends State<P2PApp> {
  late final SessionRepository _sessionRepository;

  @override
  void initState() {
    super.initState();
    _sessionRepository = const SupabaseSessionRepository();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P2P Showrooms',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: _SessionAwareSplash(sessionRepository: _sessionRepository),
      routes: {
        '/admin-login': (_) => const AdminLoginPage(),
        '/admin-mode': (_) => const AdminModeGatewayPage(),
        '/admin-dashboard': (_) => const AdminDashboardGuardPage(),
      },
    );
  }
}

class _SessionAwareSplash extends StatefulWidget {
  const _SessionAwareSplash({required this.sessionRepository});

  final SessionRepository sessionRepository;

  @override
  State<_SessionAwareSplash> createState() => _SessionAwareSplashState();
}

class _SessionAwareSplashState extends State<_SessionAwareSplash> {
  late Future<bool> _ready;

  @override
  void initState() {
    super.initState();
    _ready = _resolveSession();
  }

  /// Waits for the local session (if any) to finish restoring, then reports
  /// whether a signed-in user exists. Falls back to the auth stream so a
  /// slightly late restore still lands the user straight on the home page.
  Future<bool> _resolveSession() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    final current = await widget.sessionRepository.getCurrentUser();
    if (current != null) return true;
    try {
      final restored = await widget.sessionRepository
          .authStateChanges()
          .timeout(const Duration(seconds: 6))
          .first;
      return restored != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SplashPage(
            nextPage: const ColoredBox(color: AppColors.paper),
          );
        }
        return SplashPage(
          nextPage: (snapshot.data ?? false)
              ? const CustomerShell()
              : const AuthLandingPage(),
        );
      },
    );
  }
}
