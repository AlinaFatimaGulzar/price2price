import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../showrooms/domain/showroom.dart';
import '../domain/admin_showroom_repository.dart';
import 'admin_log_repository.dart';

class SupabaseAdminShowroomRepository implements AdminShowroomRepository {
  const SupabaseAdminShowroomRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<List<Showroom>> getAllShowrooms() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('showrooms')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Showroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Showroom>> searchAllShowrooms(String query) async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('showrooms')
          .select()
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Showroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Showroom> createShowroom(Showroom showroom) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    final response = await client
        .from('showrooms')
        .insert(showroom.toInsertJson())
        .select()
        .single();

    await _logAdminAction(
      'create_showroom',
      'Created showroom ${showroom.name}',
    );

    return Showroom.fromJson(response);
  }

  @override
  Future<Showroom> updateShowroom(Showroom showroom) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    final response = await client
        .from('showrooms')
        .update(showroom.toUpdateJson())
        .eq('id', showroom.id)
        .select()
        .single();

    await _logAdminAction(
      'update_showroom',
      'Updated showroom ${showroom.name}',
    );

    return Showroom.fromJson(response);
  }

  @override
  Future<void> deleteShowroom(int id) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    await client.from('showrooms').delete().eq('id', id);

    await _logAdminAction('delete_showroom', 'Deleted showroom id=$id');
  }

  @override
  Future<void> updateShowroomStatus(int id, String status) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    await client.from('showrooms').update({'status': status}).eq('id', id);

    await _logAdminAction(
      'update_showroom_status',
      'Set showroom id=$id status to $status',
    );
  }

  @override
  Future<void> approveShowroom(int id) async {
    await updateShowroomStatus(id, 'approved');
  }

  @override
  Future<void> rejectShowroom(int id) async {
    await updateShowroomStatus(id, 'rejected');
  }

  Future<void> _logAdminAction(String action, String description) async {
    await const SupabaseAdminLogRepository().record(action, description);
  }
}
