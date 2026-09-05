import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/showroom.dart';

abstract interface class ShowroomRepository {
  Future<List<Showroom>> getApprovedShowrooms();
  Future<Showroom?> getShowroomById(int id);
  Future<List<Showroom>> searchShowrooms(String query);
}

class SupabaseShowroomRepository implements ShowroomRepository {
  const SupabaseShowroomRepository();

  @override
  Future<List<Showroom>> getApprovedShowrooms() async {
    final client = SupabaseBootstrap.client;
    if (client == null) return [];

    try {
      final response = await client
          .from('showrooms')
          .select()
          .eq('status', 'approved')
          .order('average_rating', ascending: false);

      return (response as List)
          .map((json) => Showroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Showroom?> getShowroomById(int id) async {
    final client = SupabaseBootstrap.client;
    if (client == null) return null;

    try {
      final response = await client
          .from('showrooms')
          .select()
          .eq('id', id)
          .single();

      return Showroom.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Showroom>> searchShowrooms(String query) async {
    final client = SupabaseBootstrap.client;
    if (client == null) return [];

    try {
      final response = await client
          .from('showrooms')
          .select()
          .eq('status', 'approved')
          .ilike('name', '%$query%');

      return (response as List)
          .map((json) => Showroom.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
