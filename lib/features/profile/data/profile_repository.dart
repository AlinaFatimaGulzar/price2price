import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/user_profile.dart';

/// Reads the signed-in user's profile row with a graceful fallback to the
/// auth identity when the profiles row is not yet populated.
abstract interface class ProfileRepository {
  Future<UserProfile?> getProfile();
}

class SupabaseProfileRepository implements ProfileRepository {
  const SupabaseProfileRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<UserProfile?> getProfile() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return null;

    try {
      final response = await client
          .from('profiles')
          .select('id, email, full_name, role')
          .eq('id', user.id)
          .maybeSingle();
      if (response != null) {
        return UserProfile(
          id: response['id'] as String,
          email: (response['email'] as String?) ?? user.email ?? '',
          fullName: response['full_name'] as String?,
          role: response['role'] as String?,
        );
      }
    } catch (_) {
      // Fall through to the auth identity below.
    }

    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
    );
  }
}
