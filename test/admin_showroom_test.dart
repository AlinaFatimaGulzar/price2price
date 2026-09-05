import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/admin/domain/admin_showroom_repository.dart';
import 'package:p2p/features/admin/presentation/admin_showrooms_page.dart';
import 'package:p2p/features/admin/presentation/showroom_form_page.dart';
import 'package:p2p/features/showrooms/domain/showroom.dart';

class _FakeAdminShowroomRepository implements AdminShowroomRepository {
  bool createCalled = false;
  bool updateCalled = false;

  final List<Showroom> _showrooms = [
    Showroom(
      id: 1,
      name: 'Alpha Motors',
      address: 'GT Road',
      city: 'Gujranwala',
      status: 'approved',
      averageRating: 4.5,
      reviewCount: 3,
    ),
    Showroom(
      id: 2,
      name: 'Beta Cars',
      address: 'Model Town',
      city: 'Gujranwala',
      status: 'pending',
    ),
  ];

  @override
  Future<List<Showroom>> getAllShowrooms() async => List.of(_showrooms);

  @override
  Future<List<Showroom>> searchAllShowrooms(String query) async => _showrooms
      .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
      .toList();

  @override
  Future<Showroom> createShowroom(Showroom showroom) async {
    createCalled = true;
    return showroom.copyWith(id: 99);
  }

  @override
  Future<Showroom> updateShowroom(Showroom showroom) async {
    updateCalled = true;
    return showroom;
  }

  @override
  Future<void> deleteShowroom(int id) async {}

  @override
  Future<void> updateShowroomStatus(int id, String status) async {}

  @override
  Future<void> approveShowroom(int id) async {}

  @override
  Future<void> rejectShowroom(int id) async {}
}

void main() {
  group('Admin Showroom Form', () {
    Future<_FakeAdminShowroomRepository> pumpForm(WidgetTester tester) async {
      final fake = _FakeAdminShowroomRepository();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ShowroomFormPage(repository: fake),
        ),
      );
      return fake;
    }

    testWidgets('renders all required fields', (tester) async {
      await pumpForm(tester);
      await tester.pumpAndSettle();

      expect(find.text('Name *'), findsOneWidget);
      expect(find.text('Address *'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Add Showroom'), findsNWidgets(2));
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await pumpForm(tester);
      await tester.pumpAndSettle();

      final submit = find.widgetWithText(ElevatedButton, 'Add Showroom');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Address is required'), findsOneWidget);
    });

    testWidgets('creates showroom with valid data', (tester) async {
      final fake = await pumpForm(tester);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name *'),
        'New Motors',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Address *'),
        'Some Road',
      );
      final submit = find.widgetWithText(ElevatedButton, 'Add Showroom');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(fake.createCalled, isTrue);
    });
  });

  group('Admin Showrooms Page', () {
    Future<void> pumpPage(
      WidgetTester tester,
      _FakeAdminShowroomRepository fake,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: AdminShowroomsPage(repository: fake)),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('renders header, add button and showrooms', (tester) async {
      final fake = _FakeAdminShowroomRepository();
      await pumpPage(tester, fake);

      expect(find.text('Manage Showrooms'), findsOneWidget);
      expect(find.text('Add Showroom'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Alpha Motors'), findsOneWidget);
      expect(find.text('Beta Cars'), findsOneWidget);
      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('navigates to form on add button tap', (tester) async {
      final fake = _FakeAdminShowroomRepository();
      await pumpPage(tester, fake);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Showroom'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(ShowroomFormPage), findsOneWidget);
    });
  });
}
