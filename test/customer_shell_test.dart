import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/features/auth/data/session_repository.dart';
import 'package:p2p/features/cars/data/customer_car_repository.dart';
import 'package:p2p/features/cars/domain/car.dart';
import 'package:p2p/features/customer/presentation/customer_shell.dart';
import 'package:p2p/features/profile/data/profile_repository.dart';
import 'package:p2p/features/profile/domain/user_profile.dart';
import 'package:p2p/features/reviews/data/review_repository.dart';
import 'package:p2p/features/reviews/domain/showroom_review.dart';
import 'package:p2p/features/showrooms/data/showroom_repository.dart';
import 'package:p2p/features/showrooms/domain/showroom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('CustomerShell bottom navigation', () {
    testWidgets('defaults to Home tab with showrooms', (tester) async {
      final showrooms = [
        Showroom(
          id: 1,
          name: 'Prime Auto',
          address: 'Main Bazaar',
          status: 'approved',
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: CustomerShell(
            showroomRepository: _FakeShowroomRepository(showrooms),
            carRepository: _FakeCarRepository(const []),
            profileRepository: _FakeProfileRepository(),
            reviewRepository: _FakeReviewRepository(),
            sessionRepository: _FakeSessionRepository(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Cars'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Prime Auto'), findsWidgets);
    });

    testWidgets('switching to Cars tab shows browse cars', (tester) async {
      final cars = [Car(
        id: 1,
        showroomId: 1,
        title: 'Corolla Grande',
        brand: 'Toyota',
        model: 'Corolla',
        year: 2021,
        price: 2500000,
        km: 35000,
        fuel: 'petrol',
        transmission: 'automatic',
        condition: 'used',
        description: 'Well maintained.',
        status: 'approved',
      )];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: CustomerShell(
            showroomRepository: _FakeShowroomRepository(const []),
            carRepository: _FakeCarRepository(cars),
            profileRepository: _FakeProfileRepository(),
            reviewRepository: _FakeReviewRepository(),
            sessionRepository: _FakeSessionRepository(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Cars'));
      await tester.pumpAndSettle();

      expect(find.text('Browse Cars'), findsWidgets);
      expect(find.text('Corolla Grande'), findsOneWidget);
    });

    testWidgets('switching to Profile tab shows account', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: CustomerShell(
            showroomRepository: _FakeShowroomRepository(const []),
            carRepository: _FakeCarRepository(const []),
            profileRepository: _FakeProfileRepository(),
            reviewRepository: _FakeReviewRepository(),
            sessionRepository: _FakeSessionRepository(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('My Account'), findsOneWidget);
      expect(find.text('Ayesha Khan'), findsWidgets);
    });
  });
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
      showrooms
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
}

class _FakeCarRepository implements CustomerCarRepository {
  _FakeCarRepository(this.cars);

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

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile() async =>
      const UserProfile(id: 'u1', email: 'ayesha@example.com', fullName: 'Ayesha Khan');
}

class _FakeReviewRepository implements ReviewRepository {
  @override
  Future<List<ShowroomReview>> getApprovedForShowroom(int showroomId) async =>
      const [];

  @override
  Future<ShowroomReview?> getMyReview(int showroomId) async => null;

  @override
  Future<List<ShowroomReview>> getMyReviews() async => const [];

  @override
  Future<ShowroomReview> addReview({
    required int showroomId,
    required int rating,
    required String comment,
  }) async => throw UnimplementedError();

  @override
  Future<void> updateReview(
    int reviewId, {
    required int rating,
    required String comment,
  }) async {}

  @override
  Future<List<ShowroomReview>> getAllReviews() async => const [];

  @override
  Future<void> setReviewStatus(int reviewId, String status) async {}

  @override
  Future<void> deleteReview(int reviewId) async {}
}

class _FakeSessionRepository implements SessionRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<void> logout() async {}

  @override
  Stream<User?> authStateChanges() => const Stream.empty();
}