import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:p2p/app/theme/app_theme.dart';
import 'package:p2p/core/services/launch_service.dart';
import 'package:p2p/features/cars/data/customer_car_repository.dart';
import 'package:p2p/features/cars/domain/car.dart';
import 'package:p2p/features/customer/presentation/car_detail_page.dart';
import 'package:p2p/features/customer/presentation/showroom_detail_page.dart';
import 'package:p2p/features/showrooms/data/showroom_repository.dart';
import 'package:p2p/features/showrooms/domain/showroom.dart';

class _RecordingLaunchService implements LaunchService {
  final List<String> calls = [];
  final List<String> whatsApps = [];
  final List<String> emails = [];
  final List<String> maps = [];

  @override
  Future<bool> call(String phoneNumber) async {
    calls.add(phoneNumber);
    return true;
  }

  @override
  Future<bool> whatsApp({required String phoneNumber, String? message}) async {
    whatsApps.add(phoneNumber);
    return true;
  }

  @override
  Future<bool> mailTo({required String email, String? subject}) async {
    emails.add(email);
    return true;
  }

  @override
  Future<bool> openMap(
    String address, {
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    maps.add(address);
    return true;
  }
}

Car _car() => Car(
  id: 1,
  showroomId: 1,
  title: 'Corolla Grande',
  brand: 'Toyota',
  model: 'Corolla',
  year: 2021,
  price: 2500000,
  status: 'approved',
);

Showroom _showroom() => Showroom(
  id: 1,
  name: 'Prime Auto',
  address: 'Main Bazaar',
  city: 'Gujranwala',
  phone: '03001234567',
  whatsapp: '03001234567',
  email: 'info@primeauto.pk',
  latitude: 32.0833,
  longitude: 74.1826,
  status: 'approved',
);

void main() {
  group('UrlLaunchService normalization', () {
    test('call: local number becomes +92', () {
      expect(
        UrlLaunchService.normalizePhoneForCall('0300-1234567'),
        '+923001234567',
      );
    });

    test('call: 92-prefixed number without + stays +92', () {
      expect(
        UrlLaunchService.normalizePhoneForCall('92300-1234567'),
        '+923001234567',
      );
    });

    test('call: 11-digit number without 0 gets +92 prefix', () {
      expect(
        UrlLaunchService.normalizePhoneForCall('3001234567'),
        '+923001234567',
      );
    });

    test('call: keeps an existing +', () {
      expect(
        UrlLaunchService.normalizePhoneForCall('+1-202-555-0143'),
        '+12025550143',
      );
    });

    test('whatsapp: local number 0XXXXXXXXX becomes 92XXXXXXXXX', () {
      expect(
        UrlLaunchService.normalizePhoneForWhatsApp('03001234567'),
        '923001234567',
      );
    });

    test('whatsapp: +92 number keeps 92XXXXXXXXX', () {
      expect(
        UrlLaunchService.normalizePhoneForWhatsApp('+923001234567'),
        '923001234567',
      );
    });
  });

  group('Contact actions', () {
    testWidgets(
      'showroom detail Call/WhatsApp/email/map go through the launch service',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final launcher = _RecordingLaunchService();
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: ShowroomDetailPage(
              showroom: _showroom(),
              carRepository: _FakeCustomerCarRepository(const []),
              launchService: launcher,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text('Call'));
        await tester.tap(find.text('WhatsApp'));
        await tester.tap(find.byIcon(Icons.mail_outline));
        await tester.tap(find.byIcon(Icons.map_outlined));

        expect(launcher.calls, ['03001234567']);
        expect(launcher.whatsApps, ['03001234567']);
        expect(launcher.emails, ['info@primeauto.pk']);
        expect(launcher.maps, ['Main Bazaar']);
      },
    );

    testWidgets(
      'car detail showroom panel Call/WhatsApp go through the launch service',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final launcher = _RecordingLaunchService();
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: CarDetailPage(
              car: _car(),
              showroomRepository: _SingleShowroomRepository(_showroom()),
              launchService: launcher,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text('Call'));
        await tester.tap(find.text('WhatsApp'));

        expect(launcher.calls, ['03001234567']);
        expect(launcher.whatsApps, ['03001234567']);
      },
    );
  });
}

class _FakeCustomerCarRepository implements CustomerCarRepository {
  _FakeCustomerCarRepository(this.cars);

  final List<Car> cars;

  @override
  Future<List<Car>> getApprovedCars() async => cars;

  @override
  Future<List<Car>> getCarsForShowroom(int showroomId) async =>
      cars.where((c) => c.showroomId == showroomId).toList();

  @override
  Future<Car?> getCarById(int id) async => null;
}

class _SingleShowroomRepository implements ShowroomRepository {
  _SingleShowroomRepository(this.showroom);

  final Showroom showroom;

  @override
  Future<List<Showroom>> getApprovedShowrooms() async => [showroom];

  @override
  Future<Showroom?> getShowroomById(int id) async => showroom;

  @override
  Future<List<Showroom>> searchShowrooms(String query) async => [];
}
