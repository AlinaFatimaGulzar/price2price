import 'package:flutter/material.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../core/utils/formatters.dart';
import '../../admin/data/admin_log_repository.dart';
import '../data/review_repository.dart';
import '../domain/showroom_review.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({
    super.key,
    this.repository,
    this.logRepository = const SupabaseAdminLogRepository(),
  });

  final ReviewRepository? repository;
  final AdminLogRepository logRepository;

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  late final ReviewRepository _repository =
      widget.repository ?? const SupabaseReviewRepository();

  List<ShowroomReview> _reviews = [];
  Map<int, String> _showroomNames = {};
  bool _loading = true;
  String _error = '';
  int? _workingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    final reviews = await _repository.getAllReviews();
    final names = await _loadShowroomNames();
    if (!mounted) return;
    setState(() {
      _reviews = reviews;
      _showroomNames = names;
      _loading = false;
    });
  }

  Future<Map<int, String>> _loadShowroomNames() async {
    final client = SupabaseBootstrap.client;
    if (client == null) return {};
    try {
      final response = await client.from('showrooms').select('id,name');
      return {
        for (final row in (response as List))
          (row as Map<String, dynamic>)['id'] as int: row['name'] as String,
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> _approve(ShowroomReview review) async {
    await _setStatus(review, 'approved');
  }

  Future<void> _delete(ShowroomReview review) async {
    setState(() => _workingId = review.id);
    await _repository.deleteReview(review.id);
    await widget.logRepository.record(
      'delete_review',
      'Deleted review id=${review.id}',
    );
    if (!mounted) return;
    setState(() {
      _reviews = [..._reviews.where((r) => r.id != review.id)];
      _workingId = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Review deleted')));
  }

  Future<void> _setStatus(ShowroomReview review, String status) async {
    setState(() => _workingId = review.id);
    await _repository.setReviewStatus(review.id, status);
    await widget.logRepository.record(
      status == 'approved' ? 'approve_review' : 'reject_review',
      'Set review id=${review.id} status to $status',
    );
    if (!mounted) return;
    setState(() {
      _reviews = [
        for (final r in _reviews)
          if (r.id == review.id)
            ShowroomReview(
              id: r.id,
              showroomId: r.showroomId,
              userId: r.userId,
              rating: r.rating,
              comment: r.comment,
              status: status,
              createdAt: r.createdAt,
              updatedAt: r.updatedAt,
            )
          else
            r,
      ];
      _workingId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
            ? Center(child: Text(_error))
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Manage Reviews',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      Text(
                        '${_reviews.length} total',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No reviews yet',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                  else
                    for (final review in _reviews) ...[
                      _AdminReviewCard(
                        review: review,
                        showroomName:
                            _showroomNames[review.showroomId] ??
                            'Showroom #${review.showroomId}',
                        busy: _workingId == review.id,
                        onApprove: review.status == 'pending'
                            ? () => _approve(review)
                            : null,
                        onDelete: () => _delete(review),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
      ),
    );
  }
}

class _AdminReviewCard extends StatelessWidget {
  const _AdminReviewCard({
    required this.review,
    required this.showroomName,
    required this.busy,
    required this.onApprove,
    required this.onDelete,
  });

  final ShowroomReview review;
  final String showroomName;
  final bool busy;
  final VoidCallback? onApprove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isPending = review.status == 'pending';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    showroomName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                _StatusChip(pending: isPending),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < 5; i++)
                  Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: Colors.amber,
                  ),
                const SizedBox(width: 10),
                Text(
                  'Verified customer · ${relativeTime(review.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
            if (busy) ...[
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ] else
              Row(
                children: [
                  if (onApprove != null)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                        ),
                        onPressed: onApprove,
                        child: const Text('Approve'),
                      ),
                    ),
                  if (onApprove != null) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: onDelete,
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.pending});

  final bool pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pending ? const Color(0xFFFFF4E0) : const Color(0xFFE7F5EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        pending ? 'PENDING' : 'APPROVED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: pending ? const Color(0xFFB26A00) : const Color(0xFF1E7A46),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
