import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/dashboard_stats.dart';
import '../domain/dashboard_stats_repository.dart';

class SupabaseDashboardStatsRepository implements DashboardStatsRepository {
  const SupabaseDashboardStatsRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<DashboardStats> getStats() async {
    final client = _client;
    if (client == null) {
      return DashboardStats(
        showrooms: 0,
        pendingShowrooms: 0,
        cars: 0,
        pendingCars: 0,
        reviews: 0,
        activeUsers: 0,
        avgRating: 0,
        recentActivity: const [],
      );
    }

    try {
      final showrooms = await client.from('showrooms').select('id');
      final pendingShowrooms = await client
          .from('showrooms')
          .select('id')
          .eq('status', 'pending');
      final cars = await client.from('cars').select('id');
      final pendingCars = await client
          .from('cars')
          .select('id')
          .eq('status', 'pending');
      final reviews = await client.from('reviews').select('id');
      final activeUsers = await client.from('profiles').select('id');

      final ratingResp = await client
          .from('showrooms')
          .select('average_rating, review_count');

      double totalScore = 0;
      int totalReviews = 0;
      for (final row in (ratingResp as List)) {
        final r = row as Map;
        final rc = (r['review_count'] as num?)?.toDouble() ?? 0;
        final ra = (r['average_rating'] as num?)?.toDouble() ?? 0;
        totalScore += ra * rc;
        totalReviews += rc.toInt();
      }
      final avgRating = totalReviews > 0 ? totalScore / totalReviews : 0.0;

      final logs = await client
          .from('admin_logs')
          .select('action, description, created_at')
          .order('created_at', ascending: false)
          .limit(6);

      final activity = (logs as List).map((json) {
        final m = json as Map<String, dynamic>;
        return ActivityEntry(
          action: m['action'] as String? ?? 'event',
          description: m['description'] as String? ?? '',
          createdAt:
              DateTime.tryParse(m['created_at'] as String? ?? '') ??
              DateTime.now(),
        );
      }).toList();

      return DashboardStats(
        showrooms: (showrooms as List).length,
        pendingShowrooms: (pendingShowrooms as List).length,
        cars: (cars as List).length,
        pendingCars: (pendingCars as List).length,
        reviews: (reviews as List).length,
        activeUsers: (activeUsers as List).length,
        avgRating: double.parse(avgRating.toStringAsFixed(1)),
        recentActivity: activity,
      );
    } catch (_) {
      return DashboardStats(
        showrooms: 0,
        pendingShowrooms: 0,
        cars: 0,
        pendingCars: 0,
        reviews: 0,
        activeUsers: 0,
        avgRating: 0,
        recentActivity: const [],
      );
    }
  }
}
