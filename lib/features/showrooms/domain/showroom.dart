class Showroom {
  final int id;
  final String name;
  final String? description;
  final String address;
  final String city;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? website;
  final double? latitude;
  final double? longitude;
  final String status;
  final double averageRating;
  final int reviewCount;
  final DateTime createdAt;

  Showroom({
    this.id = 0,
    required this.name,
    this.description,
    required this.address,
    this.city = 'Gujranwala',
    this.phone,
    this.whatsapp,
    this.email,
    this.website,
    this.latitude,
    this.longitude,
    this.status = 'pending',
    this.averageRating = 0.0,
    this.reviewCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Showroom copyWith({
    int? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? phone,
    String? whatsapp,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    String? status,
    double? averageRating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return Showroom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
  }

  factory Showroom.fromJson(Map<String, dynamic> json) {
    return Showroom(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      city: json['city'] as String? ?? 'Gujranwala',
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'approved',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
