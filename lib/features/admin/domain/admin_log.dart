class AdminLogEntry {
  final int? id;
  final String? adminId;
  final String action;
  final String description;
  final DateTime createdAt;

  AdminLogEntry({
    this.id,
    this.adminId,
    required this.action,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AdminLogEntry.fromJson(Map<String, dynamic> json) {
    return AdminLogEntry(
      id: json['id'] as int?,
      adminId: json['admin_id'] as String?,
      action: json['action'] as String? ?? 'event',
      description: json['description'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
