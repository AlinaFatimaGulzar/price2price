class Car {
  final int id;
  final int showroomId;
  final String title;
  final String brand;
  final String? model;
  final int? year;
  final num? price;
  final int? km;
  final String? fuel;
  final String? transmission;
  final String? condition;
  final String? description;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;

  Car({
    this.id = 0,
    required this.showroomId,
    required this.title,
    required this.brand,
    this.model,
    this.year,
    this.price,
    this.km,
    this.fuel,
    this.transmission,
    this.condition,
    this.description,
    this.imageUrl,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Car copyWith({
    int? id,
    int? showroomId,
    String? title,
    String? brand,
    String? model,
    int? year,
    num? price,
    int? km,
    String? fuel,
    String? transmission,
    String? condition,
    String? description,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
  }) {
    return Car(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      price: price ?? this.price,
      km: km ?? this.km,
      fuel: fuel ?? this.fuel,
      transmission: transmission ?? this.transmission,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'showroom_id': showroomId,
      'title': title,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'km': km,
      'fuel': fuel,
      'transmission': transmission,
      'condition': condition,
      'description': description,
      'image_url': imageUrl,
      'status': status,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'showroom_id': showroomId,
      'title': title,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'km': km,
      'fuel': fuel,
      'transmission': transmission,
      'condition': condition,
      'description': description,
      'image_url': imageUrl,
      'status': status,
    };
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      showroomId: json['showroom_id'] as int,
      title: json['title'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String?,
      year: json['year'] as int?,
      price: json['price'] as num?,
      km: json['km'] as int?,
      fuel: json['fuel'] as String?,
      transmission: json['transmission'] as String?,
      condition: json['condition'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'showroom_id': showroomId,
      'title': title,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'km': km,
      'fuel': fuel,
      'transmission': transmission,
      'condition': condition,
      'description': description,
      'image_url': imageUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
