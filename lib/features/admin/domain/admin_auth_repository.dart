/// Admin authentication repository interface
/// Handles admin login and role verification
abstract interface class AdminAuthRepository {
  /// Sign in admin with email and password
  /// Throws [AdminNotConfiguredException] if Supabase not configured
  /// Throws [AuthException] on authentication failure
  Future<void> signInAdmin({required String email, required String password});

  /// Check if current user is an admin
  Future<bool> isCurrentUserAdmin();

  /// Sign out admin
  Future<void> signOutAdmin();

  /// Get current admin user ID
  Future<String?> getCurrentAdminId();
}

class AdminNotConfiguredException implements Exception {
  @override
  String toString() => 'Admin authentication not configured';
}
