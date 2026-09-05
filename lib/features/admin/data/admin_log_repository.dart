import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/admin_log.dart';

/// Admin audit trail: read recent activity and record new entries.
///
/// Recording is best-effort by design — a failed log write must never fail the
/// business operation that triggered it.
abstract interface class AdminLogRepository {
  Future<List<AdminLogEntry>> getRecentLogs({int limit});
  Future<void> record(String action, String description);
}

class SupabaseAdminLogRepository implements AdminLogRepository {
  const SupabaseAdminLogRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<List<AdminLogEntry>> getRecentLogs({int limit = 100}) async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('admin_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List)
          .map((json) => AdminLogEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> record(String action, String description) async {
    final client = _client;
    if (client == null) return;

    try {
      final user = client.auth.currentUser;
      await client.from('admin_logs').insert({
        'admin_id': user?.id,
        'action': action,
        'description': description,
      });
    } catch (_) {
      // Logging failures should not block the operation.
    }
  }
}
