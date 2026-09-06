import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/cars/domain/admin_car_repository.dart';
import 'package:p2p/features/cars/domain/car.dart';
import 'package:p2p/features/cars/presentation/admin_cars_page.dart';
import 'package:p2p/features/cars/presentation/car_form_page.dart';
import 'package:p2p/features/showrooms/domain/showroom.dart';

class _FakeAdminCarRepository implements AdminCarRepository {
  bool createCalled = false;
  bool updateCalled = false;

  final List<Car> _cars = [
    Car(
      id: 1,
      showroomId: 10,
      title: 'Honda Civic',
      brand: 'Honda',
      model: 'Civic',
      year: 2019,
      price: 4500000,
      km: 45000,
      fuel: 'petrol',
      transmission: 'automatic',
      condition: 'used',
      status: 'approved',
    ),
    Car(
      id: 2,
      showroomId: 10,
      title: 'Toyota Corolla',
      brand: 'Toyota',
      model: 'Corolla',
      year: 2020,
      price: 5000000,
      status: 'pending',
    ),
  ];

  @override
  Future<List<Car>> getAllCars() async => List.of(_cars);

  @override
  Future<List<Car>> getCarsForShowroom(int showroomId) async =>
      _cars.where((c) => c.showroomId == showroomId).toList();

  @override
  Future<List<Car>> searchAllCars(String query) async => _cars
      .where((c) => c.title.toLowerCase().contains(query.toLowerCase()))
      .toList();

  @override
  Future<Car> createCar(Car car) async {
    createCalled = true;
    return car.copyWith(id: 99);
  }

  @override
  Future<Car> updateCar(Car car) async {
    updateCalled = true;
    return car;
  }

  @override
  Future<void> deleteCar(int id) async {}

  @override
  Future<void> updateCarStatus(int id, String status) async {}

  @override
  Future<void> approveCar(int id) async {}

  @override
  Future<void> rejectCar(int id) async {}

  @override
  Future<List<Showroom>> getShowroomsForDropdown() async => [
    Showroom(
      id: 10,
      name: 'Alpha Motors',
      address: 'GT Road',
      city: 'Gujranwala',
      status: 'approved',
    ),
    Showroom(
      id: 11,
      name: 'Beta Cars',
      address: 'Model Town',
      city: 'Gujranwala',
      status: 'approved',
    ),
  ];
}

void main() {
  group('Car model', () {
    test('maps fromJson and toJson correctly', () {
      final json = {
        'id': 7,
        'showroom_id': 10,
        'title': 'Honda Civic',
        'brand': 'Honda',
        'model': 'Civic',
        'year': 2019,
        'price': 4500000,
        'km': 45000,
        'fuel': 'petrol',
        'transmission': 'automatic',
        'condition': 'used',
        'description': 'Well maintained',
        'image_url': 'https://example.com/car.jpg',
        'status': 'approved',
        'created_at': '2025-01-01T10:00:00Z',
      };

      final car = Car.fromJson(json);

      expect(car.id, 7);
      expect(car.showroomId, 10);
      expect(car.title, 'Honda Civic');
      expect(car.brand, 'Honda');
      expect(car.status, 'approved');
      expect(car.createdAt, DateTime.parse('2025-01-01T10:00:00Z'));

      final roundTrip = Car.fromJson(car.toJson());
      expect(roundTrip.title, car.title);
      expect(roundTrip.year, 2019);
      expect(roundTrip.price, 4500000);
    });

    test('defaults status to pending and id to 0', () {
      final car = Car(showroomId: 1, title: 'Civic', brand: 'Honda');
      expect(car.id, 0);
      expect(car.status, 'pending');
      expect(car.createdAt, isA<DateTime>());
    });
  });

  group('Car Form', () {
    Future<_FakeAdminCarRepository> pumpForm(WidgetTester tester) async {
      final fake = _FakeAdminCarRepository();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: CarFormPage(repository: fake),
        ),
      );
      await tester.pumpAndSettle();
      return fake;
    }

    testWidgets('renders all required fields', (tester) async {
      await pumpForm(tester);

      expect(find.text('Showroom *'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Brand *'), findsOneWidget);
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Add Car'), findsNWidgets(2));
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await pumpForm(tester);

      final submit = find.widgetWithText(ElevatedButton, 'Add Car');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.text('Select a showroom'), findsOneWidget);
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Brand is required'), findsOneWidget);
    });

    testWidgets('creates car with valid data', (tester) async {
      final fake = await pumpForm(tester);

      await tester.tap(find.byType(DropdownButtonFormField<int?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alpha Motors').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title *'),
        'Honda Civic 2019',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Brand *'),
        'Honda',
      );

      final submit = find.widgetWithText(ElevatedButton, 'Add Car');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(fake.createCalled, isTrue);
    });
  });

  group('Admin Cars Page', () {
    Future<void> pumpPage(
      WidgetTester tester,
      _FakeAdminCarRepository fake,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: AdminCarsPage(repository: fake)),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('renders header, search, add button and cars', (tester) async {
      final fake = _FakeAdminCarRepository();
      await pumpPage(tester, fake);

      expect(find.text('Manage Cars'), findsOneWidget);
      expect(find.text('Add Car'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Honda Civic'), findsOneWidget);
      expect(find.text('Toyota Corolla'), findsOneWidget);
      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('PKR 4500000'), findsOneWidget);
    });

    testWidgets('navigates to form on add button tap', (tester) async {
      final fake = _FakeAdminCarRepository();
      await pumpPage(tester, fake);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Car'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CarFormPage), findsOneWidget);
    });
  });
}
