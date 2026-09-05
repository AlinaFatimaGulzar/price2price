import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../admin/data/admin_log_repository.dart';
import '../../showrooms/domain/showroom.dart';
import '../domain/admin_car_repository.dart';
import '../domain/car.dart';

class SupabaseAdminCarRepository implements AdminCarRepository {
  const SupabaseAdminCarRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<List<Car>> getAllCars() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('cars')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Car.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Car>> getCarsForShowroom(int showroomId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('cars')
          .select()
          .eq('showroom_id', showroomId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Car.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Car>> searchAllCars(String query) async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('cars')
          .select()
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Car.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Car> createCar(Car car) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    final response = await client
        .from('cars')
        .insert(car.toInsertJson())
        .select()
        .single();

    await _logAdminAction('create_car', 'Created car ${car.title}');

    return Car.fromJson(response);
  }

  @override
  Future<Car> updateCar(Car car) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    final response = await client
        .from('cars')
        .update(car.toUpdateJson())
        .eq('id', car.id)
        .select()
        .single();

    await _logAdminAction('update_car', 'Updated car ${car.title}');

    return Car.fromJson(response);
  }

  @override
  Future<void> deleteCar(int id) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    await client.from('cars').delete().eq('id', id);

    await _logAdminAction('delete_car', 'Deleted car id=$id');
  }

  @override
  Future<void> updateCarStatus(int id, String status) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    await client.from('cars').update({'status': status}).eq('id', id);

    await _logAdminAction(
      'update_car_status',
      'Set car id=$id status to $status',
    );
  }

  @override
  Future<void> approveCar(int id) async {
    await updateCarStatus(id, 'approved');
  }

  @override
  Future<void> rejectCar(int id) async {
    await updateCarStatus(id, 'rejected');
  }

  @override
  Future<List<Showroom>> getShowroomsForDropdown() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client.from('showrooms').select().order('name');

      return (response as List)
          .map((json) => Showroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _logAdminAction(String action, String description) async {
    await const SupabaseAdminLogRepository().record(action, description);
  }
}
