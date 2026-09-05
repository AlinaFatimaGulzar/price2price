import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/showroom_review.dart';

/// Customer-facing review operations.
abstract interface class ReviewRepository {
  /// Approved reviews visible to everyone for a showroom.
  Future<List<ShowroomReview>> getApprovedForShowroom(int showroomId);

  /// The current user's own review for a showroom (any status).
  Future<ShowroomReview?> getMyReview(int showroomId);

  /// All of the current user's reviews across showrooms, newest first.
  Future<List<ShowroomReview>> getMyReviews();

  /// Creates a review as the signed-in user. Status is 'pending' by default
  /// until an admin approves it. Returns the created review.
  Future<ShowroomReview> addReview({
    required int showroomId,
    required int rating,
    required String comment,
  });

  /// Edits the current user's own pending review.
  Future<void> updateReview(
    int reviewId, {
    required int rating,
    required String comment,
  });

  /// All reviews across showrooms (admin moderation).
  Future<List<ShowroomReview>> getAllReviews();

  /// Approves/rejects a review by id (admin moderation).
  Future<void> setReviewStatus(int reviewId, String status);

  /// Deletes a review by id (admin or owner).
  Future<void> deleteReview(int reviewId);
}

class SupabaseReviewRepository implements ReviewRepository {
  const SupabaseReviewRepository();

  SupabaseClient? get _client => SupabaseBootstrap.client;

  @override
  Future<List<ShowroomReview>> getApprovedForShowroom(int showroomId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('reviews')
          .select()
          .eq('showroom_id', showroomId)
          .eq('status', 'approved')
          .order('created_at', ascending: false);
      return (response as List)
          .map((r) => ShowroomReview.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ShowroomReview?> getMyReview(int showroomId) async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return null;

    try {
      final response = await client
          .from('reviews')
          .select()
          .eq('showroom_id', showroomId)
          .eq('user_id', user.id)
          .maybeSingle();
      if (response == null) return null;
      return ShowroomReview.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ShowroomReview>> getMyReviews() async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return [];

    try {
      final response = await client
          .from('reviews')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return (response as List)
          .map((r) => ShowroomReview.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ShowroomReview> addReview({
    required int showroomId,
    required int rating,
    required String comment,
  }) async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      throw StateError('Sign in required to review a showroom');
    }

    final response = await client
        .from('reviews')
        .insert({
          'showroom_id': showroomId,
          'user_id': user.id,
          'rating': rating.clamp(1, 5),
          'comment': comment.trim(),
        })
        .select()
        .single();
    return ShowroomReview.fromJson(response);
  }

  @override
  Future<void> updateReview(
    int reviewId, {
    required int rating,
    required String comment,
  }) async {
    final client = _client;
    if (client == null) return;
    await client
        .from('reviews')
        .update({'rating': rating.clamp(1, 5), 'comment': comment.trim()})
        .eq('id', reviewId);
  }

  @override
  Future<List<ShowroomReview>> getAllReviews() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('reviews')
          .select()
          .order('created_at', ascending: false);
      return (response as List)
          .map((r) => ShowroomReview.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> setReviewStatus(int reviewId, String status) async {
    final client = _client;
    if (client == null) return;
    await client.from('reviews').update({'status': status}).eq('id', reviewId);
  }

  @override
  Future<void> deleteReview(int reviewId) async {
    final client = _client;
    if (client == null) return;
    await client.from('reviews').delete().eq('id', reviewId);
  }
}
