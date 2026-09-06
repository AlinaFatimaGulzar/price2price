import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../auth/data/session_repository.dart';
import '../../cars/presentation/admin_cars_page.dart';
import '../../dashboard/data/supabase_dashboard_stats_repository.dart';
import '../../dashboard/domain/dashboard_stats.dart';
import '../../dashboard/domain/dashboard_stats_repository.dart';
import '../../reviews/presentation/admin_reviews_page.dart';
import 'admin_logs_page.dart';
import 'admin_showrooms_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  bool _isLoggingOut = false;
  final SessionRepository _sessionRepository =
      const SupabaseSessionRepository();

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _sessionRepository.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoggingOut ? null : _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.store),
                label: Text('Showrooms'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_car),
                label: Text('Cars'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star),
                label: Text('Reviews'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('Logs'),
              ),
            ],
          ),
          // Main Content Area
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                DashboardOverviewPage(),
                AdminShowroomsPage(),
                AdminCarsPage(),
                AdminReviewsPage(),
                AdminLogsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dashboard Overview
class DashboardOverviewPage extends StatefulWidget {
  const DashboardOverviewPage({super.key, this.repository});

  final DashboardStatsRepository? repository;

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  late final DashboardStatsRepository _repository =
      widget.repository ?? const SupabaseDashboardStatsRepository();
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _repository.getStats();
  }

  void _reload() {
    setState(() {
      _statsFuture = _repository.getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              IconButton(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<DashboardStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _reload,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final stats = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2,
                        ),
                    children: [
                      _StatCard(
                        title: 'Total Showrooms',
                        value: '${stats.showrooms}',
                        icon: Icons.store,
                      ),
                      _StatCard(
                        title: 'Total Cars',
                        value: '${stats.cars}',
                        icon: Icons.directions_car,
                      ),
                      _StatCard(
                        title: 'Total Reviews',
                        value: '${stats.reviews}',
                        icon: Icons.star,
                      ),
                      _StatCard(
                        title: 'Pending Approvals',
                        value: '${stats.pendingApprovals}',
                        icon: Icons.pending_actions,
                        isAlert: stats.pendingApprovals > 0,
                      ),
                      _StatCard(
                        title: 'Active Users',
                        value: '${stats.activeUsers}',
                        icon: Icons.people,
                      ),
                      _StatCard(
                        title: 'Avg Rating',
                        value: '${stats.avgRating}',
                        icon: Icons.trending_up,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (stats.recentActivity.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('No recent activity yet'),
                      ),
                    )
                  else
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          for (
                            var i = 0;
                            i < stats.recentActivity.length;
                            i++
                          ) ...[
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.sage,
                                child: const Icon(
                                  Icons.history,
                                  color: AppColors.ink,
                                  size: 18,
                                ),
                              ),
                              title: Text(stats.recentActivity[i].action),
                              subtitle: Text(
                                stats.recentActivity[i].description.isEmpty
                                    ? stats.recentActivity[i].action
                                    : stats.recentActivity[i].description,
                              ),
                              trailing: Text(
                                _formatTime(stats.recentActivity[i].createdAt),
                              ),
                            ),
                            if (i < stats.recentActivity.length - 1)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isAlert = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isAlert ? const Color(0x1FFF8A80) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  color: isAlert ? AppColors.danger : AppColors.accent,
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isAlert ? AppColors.danger : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
