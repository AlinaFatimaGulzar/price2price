import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../admin/data/supabase_admin_auth_repository.dart';
import '../../admin/domain/admin_auth_repository.dart';
import '../../auth/data/session_repository.dart';
import '../../customer/presentation/browse_cars_page.dart';
import '../../customer/presentation/showroom_detail_page.dart';
import '../../customer/presentation/widgets/customer_showroom_card.dart';
import '../../customer/presentation/widgets/hero_header.dart';
import '../../profile/presentation/profile_page.dart';
import '../data/showroom_repository.dart';
import '../domain/showroom.dart';

class ShowroomsListPage extends StatefulWidget {
  const ShowroomsListPage({super.key});

  @override
  State<ShowroomsListPage> createState() => _ShowroomsListPageState();
}

class _ShowroomsListPageState extends State<ShowroomsListPage> {
  final ShowroomRepository _repository = const SupabaseShowroomRepository();
  final SessionRepository _sessionRepository =
      const SupabaseSessionRepository();
  final AdminAuthRepository _adminAuth = const SupabaseAdminAuthRepository();
  late Future<List<Showroom>> _showroomsFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _showroomsFuture = _repository.getApprovedShowrooms();
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _showroomsFuture = _repository.getApprovedShowrooms();
      } else {
        _showroomsFuture = _repository.searchShowrooms(query);
      }
    });
  }

  void _reload() {
    setState(() {
      _showroomsFuture = _repository.getApprovedShowrooms();
    });
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _sessionRepository.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not sign out')));
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P Showrooms'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'My account',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
            ),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Browse cars',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BrowseCarsPage()),
            ),
            icon: const Icon(Icons.directions_car),
          ),
          FutureBuilder<bool>(
            future: _adminAuth.isCurrentUserAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Admin Mode',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-mode');
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            onPressed: _isLoggingOut ? null : _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Column(
        children: [
          HeroHeader(
            title: 'Find your next\ncar in Gujranwala.',
            subtitle: 'Browse trusted showrooms and their cars',
            emoji: Icons.storefront,
            searchHint: 'Search showrooms...',
            searchController: _searchController,
            onSearchChanged: _search,
            action: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 46),
                backgroundColor: AppColors.surface.withValues(alpha: 0.9),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BrowseCarsPage()),
              ),
              icon: const Icon(Icons.directions_car, size: 18),
              label: const Text('Browse cars'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Showroom>>(
              future: _showroomsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _MessagePaneShowrooms(
                    icon: Icons.error_outline,
                    message: 'Could not load showrooms. Please try again.',
                    buttonLabel: 'Retry',
                    onButton: _reload,
                  );
                }

                final showrooms = snapshot.data ?? [];

                if (showrooms.isEmpty) {
                  return _MessagePaneShowrooms(
                    icon: Icons.store_outlined,
                    message: 'No showrooms found',
                    buttonLabel: '',
                    onButton: () {},
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1100
                        ? 3
                        : constraints.maxWidth >= 740
                        ? 2
                        : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 2.1,
                      ),
                      itemCount: showrooms.length,
                      itemBuilder: (context, index) {
                        final showroom = showrooms[index];
                        return CustomerShowroomCard(
                          showroom: showroom,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ShowroomDetailPage(showroom: showroom),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagePaneShowrooms extends StatelessWidget {
  const _MessagePaneShowrooms({
    required this.icon,
    required this.message,
    required this.buttonLabel,
    required this.onButton,
  });

  final IconData icon;
  final String message;
  final String buttonLabel;
  final VoidCallback onButton;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.mutedInk),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          if (buttonLabel.isNotEmpty) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: onButton,
              child: Text(buttonLabel),
            ),
          ],
        ],
      ),
    );
  }
}
