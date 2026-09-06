import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/status_pane.dart';
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

  int _columnsFor(double width) => width >= 1100
      ? 3
      : width >= 740
      ? 2
      : 1;

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
                foregroundColor: AppColors.accent,
                minimumSize: const Size(0, 46),
                side: BorderSide(
                  color: AppColors.accent.withValues(alpha: 0.45),
                ),
                backgroundColor: const Color(0x0FFFFFFF),
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
                  return LayoutBuilder(
                    builder: (context, constraints) => ShowroomSkeletonGrid(
                      columns: _columnsFor(constraints.maxWidth),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return StatusPane(
                    icon: Icons.error_outline,
                    message: 'Could not load showrooms.',
                    subtitle: 'Please try again.',
                    actionLabel: 'Retry',
                    onAction: _reload,
                  );
                }

                final showrooms = snapshot.data ?? [];

                if (showrooms.isEmpty) {
                  return StatusPane(
                    icon: Icons.store_outlined,
                    message: 'No showrooms found',
                    subtitle: 'Try a different search or check back soon.',
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _columnsFor(constraints.maxWidth),
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
