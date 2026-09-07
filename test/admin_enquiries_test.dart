import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/admin/presentation/admin_enquiries_page.dart';
import 'package:p2p/features/enquiries/domain/enquiry.dart';
import 'package:p2p/features/enquiries/domain/enquiry_repository.dart';

class _FakeEnquiryRepository implements EnquiryRepository {
  _FakeEnquiryRepository(this.enquiries);

  List<Enquiry> enquiries;
  final List<String> submitted = [];
  final List<String> statusUpdates = [];

  @override
  Future<void> submitEnquiry({
    required String name,
    required String phone,
    required String message,
    int? carId,
    int? showroomId,
    String? carTitle,
    String? showroomName,
  }) async {
    submitted.add('$name|$phone|$message|$carTitle|$showroomName');
  }

  @override
  Future<List<Enquiry>> getAllEnquiries() async => enquiries;

  @override
  Future<void> updateEnquiryStatus(int id, String status) async {
    statusUpdates.add('$id:$status');
    enquiries = [
      for (final e in enquiries)
        if (e.id == id)
          Enquiry(
            id: e.id,
            name: e.name,
            phone: e.phone,
            message: e.message,
            carId: e.carId,
            showroomId: e.showroomId,
            carTitle: e.carTitle,
            showroomName: e.showroomName,
            status: status,
          )
        else
          e,
    ];
  }
}

Enquiry _enquiry(
  int id,
  String name,
  String phone,
  String message, {
  String status = 'new',
  String? carTitle,
  String? showroomName,
}) {
  return Enquiry(
    id: id,
    name: name,
    phone: phone,
    message: message,
    status: status,
    carTitle: carTitle,
    showroomName: showroomName,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('renders enquiries with details and status', (tester) async {
    final fake = _FakeEnquiryRepository([
      _enquiry(
        1,
        'Ali',
        '0300-1234567',
        'Price kitni hai?',
        carTitle: 'Honda Civic 2019',
      ),
      _enquiry(
        2,
        'Sara',
        '0321-7654321',
        'Test drive possible?',
        status: 'contacted',
        showroomName: 'Alina Motors',
      ),
    ]);

    await tester.pumpWidget(_wrap(AdminEnquiriesPage(repository: fake)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('0300-1234567'), findsOneWidget);
    expect(find.text('Price kitni hai?'), findsOneWidget);
    expect(find.text('Honda Civic 2019'), findsOneWidget);
    expect(find.text('Sara'), findsOneWidget);
    expect(find.text('Test drive possible?'), findsOneWidget);
    expect(find.text('NEW'), findsOneWidget);
    expect(find.text('CONTACTED'), findsOneWidget);
  });

  testWidgets('marks enquiry as contacted and reloads', (tester) async {
    final fake = _FakeEnquiryRepository([
      _enquiry(
        1,
        'Ali',
        '0300-1234567',
        'Price kitni hai?',
        showroomName: 'Alina Motors',
      ),
    ]);

    await tester.pumpWidget(_wrap(AdminEnquiriesPage(repository: fake)));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.widgetWithText(OutlinedButton, 'Contacted'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fake.statusUpdates, contains('1:contacted'));
    expect(find.text('CONTACTED'), findsOneWidget);
  });

  testWidgets('marks enquiry as done', (tester) async {
    final fake = _FakeEnquiryRepository([
      _enquiry(1, 'Ali', '0300-1234567', 'Price kitni hai?'),
    ]);

    await tester.pumpWidget(_wrap(AdminEnquiriesPage(repository: fake)));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(fake.statusUpdates, contains('1:done'));
    expect(find.text('DONE'), findsOneWidget);
  });

  testWidgets('shows empty state when no enquiries', (tester) async {
    final fake = _FakeEnquiryRepository([]);

    await tester.pumpWidget(_wrap(AdminEnquiriesPage(repository: fake)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No enquiries yet'), findsOneWidget);
  });
}
