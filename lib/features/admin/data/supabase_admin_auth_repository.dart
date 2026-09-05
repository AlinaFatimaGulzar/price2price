import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/admin_auth_repository.dart';

class SupabaseAdminAuthRepository implements AdminAuthRepository {
  const SupabaseAdminAuthRepository();

  @override
  Future<void> signInAdmin({
    required String email,
    required String password,
  }) async {
    final client = SupabaseBootstrap.client;
    if (client == null) throw AdminNotConfiguredException();

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password required');
    }

    await client.auth.signInWithPassword(email: email, password: password);

    if (!await isCurrentUserAdmin()) {
      await client.auth.signOut();
      throw Exception('This account does not have admin access');
    }
  }

  @override
  Future<bool> isCurrentUserAdmin() async {
    final client = SupabaseBootstrap.client;
    if (client == null) return false;

    try {
      final user = client.auth.currentUser;
      if (user == null) return false;
      final email = user.email;
      if (email == null) return false;

      final response = await client
          .from('profiles')
          .select('role')
          .or('id.eq.${user.id},email.eq.$email')
          .limit(20);

      for (final row in (response as List)) {
        final role = (row as Map)['role'];
        if (role == 'admin' || role == 'super_admin') return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> signOutAdmin() async {
    final client = SupabaseBootstrap.client;
    if (client == null) return;

    await client.auth.signOut();
  }

  @override
  Future<String?> getCurrentAdminId() async {
    final client = SupabaseBootstrap.client;
    if (client == null) return null;

    try {
      return client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }
}
