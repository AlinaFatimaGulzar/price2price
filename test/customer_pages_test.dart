import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/cars/data/customer_car_repository.dart';
import 'package:p2p/features/cars/domain/car.dart';
import 'package:p2p/features/customer/presentation/browse_cars_page.dart';
import 'package:p2p/features/customer/presentation/car_detail_page.dart';
import 'package:p2p/features/customer/presentation/showroom_detail_page.dart';
import 'package:p2p/features/reviews/data/review_repository.dart';
import 'package:p2p/features/reviews/domain/showroom_review.dart';
import 'package:p2p/features/showrooms/data/showroom_repository.dart';
import 'package:p2p/features/showrooms/domain/showroom.dart';

class _FakeCustomerCarRepository implements CustomerCarRepository {
  _FakeCustomerCarRepository(this.cars);

  final List<Car> cars;

  @override
  Future<List<Car>> getApprovedCars() async => cars;

  @override
  Future<List<Car>> getCarsForShowroom(int showroomId) async =>
      cars.where((c) => c.showroomId == showroomId).toList();

  @override
  Future<Car?> getCarById(int id) async {
    for (final car in cars) {
      if (car.id == id) return car;
    }
    return null;
  }
}

class _FakeShowroomRepository implements ShowroomRepository {
  _FakeShowroomRepository(this.showrooms);

  final List<Showroom> showrooms;

  @override
  Future<List<Showroom>> getApprovedShowrooms() async => showrooms;

  @override
  Future<Showroom?> getShowroomById(int id) async {
    for (final showroom in showrooms) {
      if (showroom.id == id) return showroom;
    }
    return null;
  }

  @override
  Future<List<Showroom>> searchShowrooms(String query) async =>
      showrooms.where((s) => s.name.toLowerCase().contains(query)).toList();
}

Car _car(int id, int showroomId, String title, {num? price = 2500000}) {
  return Car(
    id: id,
    showroomId: showroomId,
    title: title,
    brand: 'Toyota',
    model: 'Corolla',
    year: 2021,
    price: price,
    km: 35000,
    fuel: 'petrol',
    transmission: 'automatic',
    condition: 'used',
    description: 'Well maintained car.',
    status: 'approved',
  );
}

Showroom _showroom(int id, String name) {
  return Showroom(
    id: id,
    name: name,
    description: 'Trusted dealer.',
    address: 'Main Bazaar',
    phone: '0300-1234567',
    whatsapp: '0300-1234567',
    status: 'approved',
    averageRating: 4.5,
    reviewCount: 12,
  );
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
  Future<ShowroomReview?> getMyReview(int showroomId) async {
    for (final r in reviews) {
      if (r.showroomId == showroomId && r.userId == 'me') return r;
    }
    return null;
  }

  @override
  Future<List<ShowroomReview>> getMyReviews() async =>
      reviews.where((r) => r.userId == 'me').toList();

  @override
  Future<ShowroomReview> addReview({
    required int showroomId,
    required int rating,
    required String comment,
  }) async {
    final review = ShowroomReview(
      id: 99,
      showroomId: showroomId,
      userId: 'me',
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
  Future<void> setReviewStatus(int reviewId, String status) async {}

  @override
  Future<void> deleteReview(int reviewId) async {
    reviews = reviews.where((r) => r.id != reviewId).toList();
  }
}

void main() {
  group('BrowseCarsPage', () {
    testWidgets('renders cars from repository', (tester) async {
      final cars = [_car(1, 1, 'Corolla Grande'), _car(2, 1, 'Civic Oriel')];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: BrowseCarsPage(repository: _FakeCustomerCarRepository(cars)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Corolla Grande'), findsOneWidget);
      expect(find.text('Civic Oriel'), findsOneWidget);
      expect(find.text('PKR 2,500,000'), findsNWidgets(2));
    });

    testWidgets('search filters cars', (tester) async {
      final cars = [_car(1, 1, 'Corolla Grande'), _car(2, 1, 'Civic Oriel')];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: BrowseCarsPage(repository: _FakeCustomerCarRepository(cars)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'civic');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Civic Oriel'), findsOneWidget);
      expect(find.text('Corolla Grande'), findsNothing);
    });

    testWidgets('shows empty message when no cars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: BrowseCarsPage(
            repository: _FakeCustomerCarRepository(const []),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No cars match your search'), findsOneWidget);
    });

    testWidgets('tapping a car opens car detail', (tester) async {
      final cars = [_car(1, 1, 'Corolla Grande')];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: BrowseCarsPage(repository: _FakeCustomerCarRepository(cars)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Corolla Grande'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Specifications'), findsOneWidget);
    });
  });

  group('ShowroomDetailPage', () {
    testWidgets('renders showroom info and its cars', (tester) async {
      final showroom = _showroom(3, 'Prime Auto');
      final cars = [_car(10, 3, 'Prime Corolla'), _car(11, 4, 'Other Civic')];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ShowroomDetailPage(
            showroom: showroom,
            carRepository: _FakeCustomerCarRepository(cars),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Prime Auto'), findsWidgets);
      expect(find.text('Prime Corolla'), findsOneWidget);
      expect(find.text('Other Civic'), findsNothing);
      expect(find.text('Available Cars'), findsOneWidget);
    });

    testWidgets('shows empty state for showroom without cars', (tester) async {
      final showroom = _showroom(3, 'Prime Auto');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ShowroomDetailPage(
            showroom: showroom,
            carRepository: _FakeCustomerCarRepository(const []),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('No cars available at this showroom yet'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a car opens car detail', (tester) async {
      final showroom = _showroom(3, 'Prime Auto');
      final cars = [_car(10, 3, 'Prime Corolla')];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ShowroomDetailPage(
            showroom: showroom,
            carRepository: _FakeCustomerCarRepository(cars),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.ensureVisible(find.text('Prime Corolla'));
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Prime Corolla'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      await tester.tap(find.text('Prime Corolla'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Specifications'), findsOneWidget);
    });
  });

  group('CarDetailPage', () {
    testWidgets('renders car price, specs and showroom panel', (tester) async {
      final showroom = _showroom(3, 'Prime Auto');
      final car = _car(10, 3, 'Prime Corolla');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: CarDetailPage(
            car: car,
            showroomRepository: _FakeShowroomRepository([showroom]),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Prime Corolla'), findsOneWidget);
      expect(find.text('Specifications'), findsOneWidget);
      expect(find.text('PKR 2,500,000'), findsOneWidget);
      expect(find.text('Prime Auto'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
    });

    testWidgets('renders specs with missing values as dash', (tester) async {
      final car = Car(
        id: 1,
        showroomId: 3,
        title: 'Basic Car',
        brand: 'Suzuki',
        status: 'approved',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: CarDetailPage(
            car: car,
            showroomRepository: _FakeShowroomRepository(const []),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('—'), findsNWidgets(5));
      expect(find.text('Price on request'), findsOneWidget);
    });
  });

  group('Showroom reviews', () {
    void useTallViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('shows approved reviews on showroom detail', (tester) async {
      useTallViewport(tester);
      final showroom = _showroom(3, 'Prime Auto');
      final reviews = [
        ShowroomReview(
          id: 1,
          showroomId: 3,
          userId: 'u1',
          rating: 5,
          comment: 'Great experience',
          status: 'approved',
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ShowroomDetailPage(
            showroom: showroom,
            carRepository: _FakeCustomerCarRepository(const []),
            reviewRepository: _FakeReviewRepository(reviews),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('Great experience'), findsOneWidget);
      expect(find.text('Write a review'), findsOneWidget);
    });

    testWidgets('shows my pending review with pending label', (tester) async {
      useTallViewport(tester);
      final showroom = _showroom(3, 'Prime Auto');
      final reviews = [
        ShowroomReview(
          id: 1,
          showroomId: 3,
          userId: 'me',
          rating: 4,
          comment: 'My pending review',
          status: 'pending',
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ShowroomDetailPage(
            showroom: showroom,
            carRepository: _FakeCustomerCarRepository(const []),
            reviewRepository: _FakeReviewRepository(reviews),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My pending review'), findsOneWidget);
      expect(find.text('PENDING APPROVAL'), findsOneWidget);
      expect(find.text('Edit review'), findsOneWidget);
    });

    testWidgets('shows empty message when no reviews', (tester) async {
      useTallViewport(tester);
      final showroom = _showroom(3, 'Prime Auto');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ShowroomDetailPage(
            showroom: showroom,
            carRepository: _FakeCustomerCarRepository(const []),
            reviewRepository: _FakeReviewRepository(const []),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('No reviews yet. Share your experience by writing one!'),
        findsOneWidget,
      );
    });

    testWidgets(
      'submit review button enables once a star and comment are set',
      (tester) async {
        useTallViewport(tester);
        final showroom = _showroom(3, 'Prime Auto');
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: ShowroomDetailPage(
              showroom: showroom,
              carRepository: _FakeCustomerCarRepository(const []),
              reviewRepository: _FakeReviewRepository(const []),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text('Write a review'));
        await tester.pumpAndSettle();

        ElevatedButton button() => tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Submit review'),
        );
        expect(button().onPressed, isNull);

        await tester.tap(find.byIcon(Icons.star_outline_rounded).first);
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'Great cars!');
        await tester.pump();

        expect(button().onPressed, isNotNull);

        await tester.tapAt(const Offset(0, 0));
        await tester.pumpAndSettle();
      },
    );
  });
}
