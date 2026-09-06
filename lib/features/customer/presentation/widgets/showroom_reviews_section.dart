import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../reviews/data/review_repository.dart';
import '../../../reviews/domain/showroom_review.dart';

class ShowroomReviewsSection extends StatefulWidget {
  const ShowroomReviewsSection({
    super.key,
    required this.showroomId,
    this.reviewRepository,
  });

  final int showroomId;
  final ReviewRepository? reviewRepository;

  @override
  State<ShowroomReviewsSection> createState() => _ShowroomReviewsSectionState();
}

class _ShowroomReviewsSectionState extends State<ShowroomReviewsSection> {
  late final ReviewRepository _repository =
      widget.reviewRepository ?? const SupabaseReviewRepository();

  late Future<List<ShowroomReview>> _reviewsFuture;
  ShowroomReview? _myReview;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _repository.getApprovedForShowroom(widget.showroomId);
    _loadMyReview();
  }

  Future<void> _loadMyReview() async {
    final mine = await _repository.getMyReview(widget.showroomId);
    if (!mounted) return;
    setState(() => _myReview = mine);
  }

  Future<void> _refresh() async {
    setState(() {
      _reviewsFuture = _repository.getApprovedForShowroom(widget.showroomId);
    });
  }

  Future<void> _openWriteSheet() async {
    final result = await showModalBottomSheet<ShowroomReview>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _WriteReviewSheet(showroomId: widget.showroomId, initial: _myReview),
    );
    if (result == null) return;
    await _loadMyReview();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Reviews', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: _openWriteSheet,
              icon: const Icon(Icons.star_rounded, size: 18),
              label: Text(_myReview == null ? 'Write a review' : 'Edit review'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<ShowroomReview>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text(
                'Could not load reviews',
                style: Theme.of(context).textTheme.bodyLarge,
              );
            }
            final reviews = snapshot.data ?? [];

            if (_myReview != null) reviews.insert(0, _myReview!);

            if (reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No reviews yet. Share your experience by writing one!',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return Column(
              children: [
                for (final review in reviews) _ReviewTile(review: review),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ShowroomReview review;

  @override
  Widget build(BuildContext context) {
    final isPending = review.status == 'pending';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPending ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x0FFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Verified customer',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.45),
                      ),
                    ),
                    child: const Text(
                      'PENDING APPROVAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  )
                else
                  Text(
                    relativeTime(review.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < 5; i++)
                  Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: AppColors.accent,
                  ),
                const SizedBox(width: 10),
                Text(
                  '${review.rating}.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet({required this.showroomId, this.initial});

  final int showroomId;
  final ShowroomReview? initial;

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _submitting = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _rating = widget.initial?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.initial?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (_rating == 0 || comment.isEmpty) return;
    setState(() {
      _submitting = true;
      _error = '';
    });
    try {
      final repository = const SupabaseReviewRepository();
      if (widget.initial != null) {
        await repository.updateReview(
          widget.initial!.id,
          rating: _rating,
          comment: comment,
        );
      } else {
        await repository.addReview(
          showroomId: widget.showroomId,
          rating: _rating,
          comment: comment,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Could not save your review. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E1D24),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.initial == null
                        ? 'Rate this showroom'
                        : 'Edit your review',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your review is reviewed before it goes live.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => setState(() => _rating = i),
                      icon: Icon(
                        i <= _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 38,
                        color: i <= _rating
                            ? AppColors.accent
                            : AppColors.mutedInk,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                  alignLabelWithHint: true,
                ),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(_error, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _submitting ||
                          _rating == 0 ||
                          _commentController.text.trim().isEmpty
                      ? null
                      : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
