class Restaurant {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? description;
  final String status;
  final double latitude;
  final double longitude;
  final String addressLine;
  final double deliveryFee;
  final double minOrderAmount;
  final int avgPreparationMin;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final List<WorkingHour> workingHours;

  Restaurant({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.coverImageUrl,
    this.description,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.addressLine,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.avgPreparationMin,
    required this.rating,
    required this.reviewsCount,
    required this.isFeatured,
    this.workingHours = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      addressLine: json['addressLine'] as String? ?? '',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0,
      avgPreparationMin: json['avgPreparationMin'] as int? ?? 20,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      workingHours: (json['workingHours'] as List<dynamic>? ?? [])
          .map((e) => WorkingHour.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Hozirgi vaqtga nisbatan restoran ochiqmi yo'qmi (haftaning kuni + soat bo'yicha)
  bool get isOpenNow {
    if (status != 'active') return false;
    if (workingHours.isEmpty) return true;
    final now = DateTime.now();
    final today = workingHours.firstWhere(
      (w) => w.dayOfWeek == now.weekday % 7,
      orElse: () => WorkingHour(dayOfWeek: 0, opensAt: '00:00', closesAt: '23:59', isClosed: true),
    );
    if (today.isClosed) return false;
    final nowMinutes = now.hour * 60 + now.minute;
    final opens = _toMinutes(today.opensAt);
    final closes = _toMinutes(today.closesAt);
    return nowMinutes >= opens && nowMinutes <= closes;
  }

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

class WorkingHour {
  final int dayOfWeek;
  final String opensAt;
  final String closesAt;
  final bool isClosed;

  WorkingHour({
    required this.dayOfWeek,
    required this.opensAt,
    required this.closesAt,
    required this.isClosed,
  });

  factory WorkingHour.fromJson(Map<String, dynamic> json) {
    return WorkingHour(
      dayOfWeek: json['dayOfWeek'] as int,
      opensAt: json['opensAt'] as String,
      closesAt: json['closesAt'] as String,
      isClosed: json['isClosed'] as bool? ?? false,
    );
  }
}
