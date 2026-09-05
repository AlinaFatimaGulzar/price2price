import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/admin/presentation/admin_dashboard_page.dart';
import 'package:p2p/features/dashboard/domain/dashboard_stats.dart';
import 'package:p2p/features/dashboard/domain/dashboard_stats_repository.dart';

class _FakeDashboardStatsRepository implements DashboardStatsRepository {
  int fetchCount = 0;

  @override
  Future<DashboardStats> getStats() async {
    fetchCount++;
    return DashboardStats(
      showrooms: 3,
      pendingShowrooms: 1,
      cars: 5,
      pendingCars: 2,
      reviews: 12,
      activeUsers: 30,
      avgRating: 4.2,
      recentActivity: [
        ActivityEntry(
          action: 'create_car',
          description: 'Created Honda Civic',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        ActivityEntry(
          action: 'update_showroom',
          description: 'Updated City Motors',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}

void main() {
  group('DashboardOverviewPage', () {
    Future<void> pumpPage(
      WidgetTester tester,
      _FakeDashboardStatsRepository fake,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: DashboardOverviewPage(repository: fake)),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('renders header and refresh button', (tester) async {
      final fake = _FakeDashboardStatsRepository();
      await pumpPage(tester, fake);

      expect(find.text('Dashboard Overview'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows live stats from repository', (tester) async {
      final fake = _FakeDashboardStatsRepository();
      await pumpPage(tester, fake);

      expect(find.text('Total Showrooms'), findsOneWidget);
      expect(find.text('3'), findsNWidgets(2)); // showrooms + pending (1+2)
      expect(find.text('Total Cars'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Pending Approvals'), findsOneWidget);
      expect(find.text('Active Users'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('4.2'), findsOneWidget);
    });

    testWidgets('shows recent activity entries', (tester) async {
      final fake = _FakeDashboardStatsRepository();
      await pumpPage(tester, fake);

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('create_car'), findsOneWidget);
      expect(find.text('Created Honda Civic'), findsOneWidget);
      expect(find.text('update_showroom'), findsOneWidget);
      expect(find.text('Updated City Motors'), findsOneWidget);
    });

    testWidgets('reloads stats on refresh tap', (tester) async {
      final fake = _FakeDashboardStatsRepository();
      await pumpPage(tester, fake);
      expect(fake.fetchCount, 1);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      await tester.pump();

      expect(fake.fetchCount, 2);
    });
  });
}
