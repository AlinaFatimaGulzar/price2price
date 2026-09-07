class Enquiry {
  final int id;
  final String name;
  final String phone;
  final String message;
  final int? carId;
  final int? showroomId;
  final String? carTitle;
  final String? showroomName;
  final String status;
  final DateTime createdAt;

  Enquiry({
    this.id = 0,
    required this.name,
    required this.phone,
    required this.message,
    this.carId,
    this.showroomId,
    this.carTitle,
    this.showroomName,
    this.status = 'new',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get statusLabel {
    switch (status) {
      case 'contacted':
        return 'Contacted';
      case 'done':
        return 'Done';
      default:
        return 'New';
    }
  }

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      message: json['message'] as String,
      carId: json['car_id'] as int?,
      showroomId: json['showroom_id'] as int?,
      carTitle: json['car_title'] as String?,
      showroomName: json['showroom_name'] as String?,
      status: json['status'] as String? ?? 'new',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
