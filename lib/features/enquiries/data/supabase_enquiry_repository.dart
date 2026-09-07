import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../admin/data/admin_log_repository.dart';
import '../domain/enquiry.dart';
import '../domain/enquiry_repository.dart';

class SupabaseEnquiryRepository implements EnquiryRepository {
  const SupabaseEnquiryRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

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
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    await client.from('enquiries').insert({
      'name': name,
      'phone': phone,
      'message': message,
      'car_id': carId,
      'showroom_id': showroomId,
      'car_title': carTitle,
      'showroom_name': showroomName,
    });
  }

  @override
  Future<List<Enquiry>> getAllEnquiries() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('enquiries')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Enquiry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> updateEnquiryStatus(int id, String status) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase not configured');
    }

    await client.from('enquiries').update({'status': status}).eq('id', id);

    await const SupabaseAdminLogRepository().record(
      'update_enquiry_status',
      'Enquiry id=$id marked as $status',
    );
  }
}
