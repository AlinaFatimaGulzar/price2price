import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/admin/data/admin_log_repository.dart';
import 'package:p2p/features/admin/domain/admin_log.dart';
import 'package:p2p/features/admin/presentation/admin_logs_page.dart';
import 'package:p2p/features/reviews/data/review_repository.dart';
import 'package:p2p/features/reviews/domain/showroom_review.dart';
import 'package:p2p/features/reviews/presentation/admin_reviews_page.dart';

class _FakeAdminLogRepository implements AdminLogRepository {
  _FakeAdminLogRepository(this.logs);

  final List<AdminLogEntry> logs;
  final List<String> recorded = [];

  @override
  Future<List<AdminLogEntry>> getRecentLogs({int limit = 100}) async =>
      logs.take(limit).toList();

  @override
  Future<void> record(String action, String description) async {
    recorded.add(action);
  }
}

class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository(this.reviews);

  List<ShowroomReview> reviews;

  @override
  Future<List<ShowroomReview>> getApprovedForShowroom(int showroomId) async =>
      reviews
          .where((r) => r.showroomId == showroomId && r.status == 'approved')
          .toList();

  @override
  Future<ShowroomReview?> getMyReview(int showroomId) async => null;

  @override
  Future<List<ShowroomReview>> getMyReviews() async =>
      reviews.where((r) => r.userId == 'u1').toList();

  @override
  Future<ShowroomReview> addReview({
    required int showroomId,
    required int rating,
    required String comment,
  }) async {
    final review = ShowroomReview(
      id: 99,
      showroomId: showroomId,
      userId: 'u1',
      rating: rating,
      comment: comment,
    );
    reviews = [...reviews, review];
    return review;
  }

  @override
  Future<void> updateReview(
    int reviewId, {
    required int rating,
    required String comment,
  }) async {}

  @override
  Future<List<ShowroomReview>> getAllReviews() async => reviews;

  @override
  Future<void> setReviewStatus(int reviewId, String status) async {
    reviews = [
      for (final r in reviews)
        if (r.id == reviewId)
          ShowroomReview(
            id: r.id,
            showroomId: r.showroomId,
            userId: r.userId,
            rating: r.rating,
            comment: r.comment,
            status: status,
            createdAt: r.createdAt,
          )
        else
          r,
    ];
  }

  @override
  Future<void> deleteReview(int reviewId) async {
    reviews = [...reviews.where((r) => r.id != reviewId)];
  }
}

void main() {
  group('Admin panel', () {
    testWidgets('review page renders review management actions', (
      tester,
    ) async {
      final repo = _FakeReviewRepository([
        ShowroomReview(
          id: 1,
          showroomId: 1,
          userId: 'u1',
          rating: 5,
          comment: 'Great service',
          status: 'pending',
        ),
        ShowroomReview(
          id: 2,
          showroomId: 1,
          userId: 'u2',
          rating: 4,
          comment: 'Good cars',
          status: 'approved',
        ),
      ]);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AdminReviewsPage(repository: repo),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Manage Reviews'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Delete'), findsNWidgets(2));
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('APPROVED'), findsOneWidget);
    });

    testWidgets('review page approve updates status', (tester) async {
      final repo = _FakeReviewRepository([
        ShowroomReview(
          id: 1,
          showroomId: 1,
          userId: 'u1',
          rating: 5,
          comment: 'Great service',
          status: 'pending',
        ),
      ]);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AdminReviewsPage(repository: repo),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('PENDING'), findsOneWidget);
      await tester.tap(find.text('Approve'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('PENDING'), findsNothing);
    });

    testWidgets('logs page renders admin activity entries', (tester) async {
      final logs = _FakeAdminLogRepository([
        AdminLogEntry(
          action: 'create_showroom',
          description: 'Created showroom Kandha Road Motors',
          createdAt: DateTime(2026, 9, 5, 11),
        ),
        AdminLogEntry(
          action: 'approve_review',
          description: 'Set review id=3 status to approved',
          createdAt: DateTime(2026, 9, 4, 15),
        ),
      ]);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AdminLogsPage(repository: logs),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Admin Activity Logs'), findsOneWidget);
      expect(find.text('create_showroom'), findsOneWidget);
      expect(find.text('Created showroom Kandha Road Motors'), findsOneWidget);
      expect(find.text('approve_review'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('logs page shows empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AdminLogsPage(repository: _FakeAdminLogRepository(const [])),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('No admin activity yet'), findsOneWidget);
    });

    testWidgets('review approve records an admin log', (tester) async {
      final repo = _FakeReviewRepository([
        ShowroomReview(
          id: 1,
          showroomId: 1,
          userId: 'u1',
          rating: 5,
          comment: 'Great service',
          status: 'pending',
        ),
      ]);
      final logs = _FakeAdminLogRepository(const []);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AdminReviewsPage(repository: repo, logRepository: logs),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Approve'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(logs.recorded, contains('approve_review'));
    });
  });
}
