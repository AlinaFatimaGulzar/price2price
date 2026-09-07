import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../admin/data/supabase_admin_auth_repository.dart';
import '../../admin/domain/admin_auth_repository.dart';
import '../../auth/data/session_repository.dart';
import '../../auth/data/supabase_auth_repository.dart';
import '../../auth/presentation/auth_landing_page.dart';
import '../../auth/presentation/reset_password_page.dart';
import '../../reviews/data/review_repository.dart';
import '../../reviews/domain/showroom_review.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.profileRepository,
    this.reviewRepository,
    this.sessionRepository,
  });

  final ProfileRepository? profileRepository;
  final ReviewRepository? reviewRepository;
  final SessionRepository? sessionRepository;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileRepository _profileRepository =
      widget.profileRepository ?? const SupabaseProfileRepository();
  late final ReviewRepository _reviewRepository =
      widget.reviewRepository ?? const SupabaseReviewRepository();
  late final SessionRepository _sessionRepository =
      widget.sessionRepository ?? const SupabaseSessionRepository();
  final AdminAuthRepository _adminAuth = const SupabaseAdminAuthRepository();

  UserProfile? _profile;
  List<ShowroomReview> _myReviews = const [];
  bool? _isAdmin;
  bool _loading = true;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final adminFuture = _adminAuth.isCurrentUserAdmin().catchError((_) => false);
    final results = await Future.wait([
      _profileRepository.getProfile(),
      _reviewRepository.getMyReviews(),
    ]);
    final isAdmin = await adminFuture;
    if (!mounted) return;
    setState(() {
      _profile = results[0] as UserProfile?;
      _myReviews = results[1] as List<ShowroomReview>;
      _isAdmin = isAdmin;
      _loading = false;
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => LiquidDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log out?',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You can sign back in whenever you like — your session stays saved.',
              style: TextStyle(color: AppColors.mutedInk, height: 1.5),
            ),
            SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Log out'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);
    try {
      await _sessionRepository.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AuthLandingPage()),
        (route) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _loggingOut = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not sign out')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final approved = _myReviews.where((r) => r.status == 'approved').length;
    final pending = _myReviews.length - approved;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          children: [
            Text(
              'My Account',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your profile and reviews',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _ProfileHeader(profile: _profile),
            const SizedBox(height: 18),
            _StatsTile(approved: approved, pending: pending),
            const SizedBox(height: 26),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.lock_reset,
              title: 'Change password',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ResetPasswordPage(
                    repository: SupabaseAuthRepository(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_isAdmin == true) ...[
              _MenuTile(
                icon: Icons.admin_panel_settings,
                title: 'Admin Mode',
                onTap: () => Navigator.of(context).pushNamed('/admin-mode'),
              ),
              const SizedBox(height: 10),
            ],
            _MenuTile(
              icon: Icons.login,
              title: _loggingOut ? 'Logging out…' : 'Log out',
              destructive: true,
              enabled: !_loggingOut,
              onTap: _confirmLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.profile});

  final UserProfile? profile;

  String get _initials {
    final name = profile?.fullName ?? profile?.email ?? 'U';
    final parts = name
        .split(RegExp(r'[@\s.]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    final first = parts.first[0].toUpperCase();
    final second = parts.length > 1 ? parts[1][0].toUpperCase() : '';
    return '$first$second';
  }

  @override
  Widget build(BuildContext context) {
    final name = profile?.fullName?.trim() ?? 'Car Enthusiast';
    final email = profile?.email ?? '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16303F), Color(0xFF0A151C)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.accent,
            child: Text(
              _initials,
              style: const TextStyle(
                color: AppColors.onAccent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Verified buyer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  const _StatsTile({required this.approved, required this.pending});

  final int approved;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _stat(label: 'Reviews', value: '${approved + pending}'),
          _divider(),
          _stat(label: 'Live', value: '$approved'),
          _divider(),
          _stat(label: 'Pending', value: '$pending'),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: AppColors.border);

  Widget _stat({required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.mutedInk, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.destructive = false,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.ink;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.mutedInk),
            ],
          ),
        ),
      ),
    );
  }
}
