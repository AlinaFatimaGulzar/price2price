import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../data/supabase_admin_auth_repository.dart';
import '../domain/admin_auth_repository.dart';
import 'admin_dashboard_page.dart';

class AdminModeGatewayPage extends StatefulWidget {
  const AdminModeGatewayPage({super.key});

  @override
  State<AdminModeGatewayPage> createState() => _AdminModeGatewayPageState();
}

class AdminDashboardGuardPage extends StatefulWidget {
  const AdminDashboardGuardPage({super.key});

  @override
  State<AdminDashboardGuardPage> createState() =>
      _AdminDashboardGuardPageState();
}

class _AdminDashboardGuardPageState extends State<AdminDashboardGuardPage> {
  final AdminAuthRepository _adminAuth = const SupabaseAdminAuthRepository();
  late Future<bool> _checkAdminStatus;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus = _adminAuth.isCurrentUserAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAdminStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) return const AdminDashboardPage();

        return const AdminModeGatewayPage();
      },
    );
  }
}

class _AdminModeGatewayPageState extends State<AdminModeGatewayPage> {
  final AdminAuthRepository _adminAuth = const SupabaseAdminAuthRepository();
  late Future<bool> _checkAdminStatus;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus = _adminAuth.isCurrentUserAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAdminStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          // User is admin, show option to enter admin dashboard
          return _AdminAccessPage();
        }

        // User is not admin
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 88, color: AppColors.mutedInk),
                const SizedBox(height: 24),
                Text(
                  'Admin Access Required',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 14),
                Text(
                  'You do not have admin privileges',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminAccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Access'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 88,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Admin',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 14),
                Text(
                  'Access the P2P admin dashboard to manage showrooms, cars, and reviews',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin-dashboard');
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Enter Admin Dashboard'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
