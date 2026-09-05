class ShowroomReview {
  final int id;
  final int showroomId;
  final String userId;
  final int rating;
  final String comment;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ShowroomReview({
    this.id = 0,
    required this.showroomId,
    required this.userId,
    required this.rating,
    required this.comment,
    this.status = 'pending',
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ShowroomReview.fromJson(Map<String, dynamic> json) {
    return ShowroomReview(
      id: json['id'] as int,
      showroomId: json['showroom_id'] as int,
      userId: json['user_id'] as String? ?? '',
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'showroom_id': showroomId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
