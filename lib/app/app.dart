import 'package:flutter/material.dart';

import '../features/auth/data/session_repository.dart';
import '../features/auth/presentation/auth_landing_page.dart';
import '../features/home/presentation/home_page.dart';
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
      theme: AppTheme.light.copyWith(
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
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1800));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SplashPage(nextPage: _buildNextPage());
        }
        return _buildNextPage();
      },
    );
  }

  Widget _buildNextPage() {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPage(nextPage: Container(color: Colors.white));
        }
        if (snapshot.data == true) {
          return const HomePage();
        }
        return const AuthLandingPage();
      },
    );
  }

  Future<bool> _isUserLoggedIn() async {
    final user = await widget.sessionRepository.getCurrentUser();
    return user != null;
  }
}
