class Address {
  final String id;
  final String? title;
  final String type; // home | work | other
  final String addressLine;
  final String? entrance;
  final String? floor;
  final String? apartment;
  final String? comment;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Address({
    required this.id,
    this.title,
    required this.type,
    required this.addressLine,
    this.entrance,
    this.floor,
    this.apartment,
    this.comment,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      title: json['title'] as String?,
      type: json['type'] as String? ?? 'home',
      addressLine: json['addressLine'] as String,
      entrance: json['entrance'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      comment: json['comment'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type,
        'addressLine': addressLine,
        'entrance': entrance,
        'floor': floor,
        'apartment': apartment,
        'comment': comment,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };
}
