import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';

abstract interface class SessionRepository {
  Future<User?> getCurrentUser();
  Future<void> logout();
  Stream<User?> authStateChanges();
}

class SupabaseSessionRepository implements SessionRepository {
  const SupabaseSessionRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<User?> getCurrentUser() async {
    return _client?.auth.currentUser;
  }

  @override
  Future<void> logout() async {
    await _client?.auth.signOut();
  }

  @override
  Stream<User?> authStateChanges() {
    return _client?.auth.onAuthStateChange.map((data) => data.session?.user) ??
        const Stream.empty();
  }
}
