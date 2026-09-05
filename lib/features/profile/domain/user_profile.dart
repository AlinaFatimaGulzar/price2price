class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.role,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? role;

  bool get isAdmin => role == 'admin' || role == 'super_admin';
}
