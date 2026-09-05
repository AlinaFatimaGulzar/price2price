import 'dashboard_stats.dart';

abstract interface class DashboardStatsRepository {
  Future<DashboardStats> getStats();
}
