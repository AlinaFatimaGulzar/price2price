import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../cars/domain/car.dart';

abstract interface class CustomerCarRepository {
  Future<List<Car>> getApprovedCars();
  Future<Car?> getCarById(int id);
  Future<List<Car>> getCarsForShowroom(int showroomId);
}

class SupabaseCustomerCarRepository implements CustomerCarRepository {
  const SupabaseCustomerCarRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<List<Car>> getApprovedCars() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('cars')
          .select()
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Car.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Car?> getCarById(int id) async {
    final client = _client;
    if (client == null) return null;

    try {
      final response = await client
          .from('cars')
          .select()
          .eq('id', id)
          .eq('status', 'approved')
          .maybeSingle();

      if (response == null) return null;
      return Car.fromJson(response);
    } catch (_) {
      return null;
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
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Car.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
