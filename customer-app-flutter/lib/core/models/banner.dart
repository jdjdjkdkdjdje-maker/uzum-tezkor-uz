class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? linkType;
  final String? linkValue;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkType,
    this.linkValue,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      linkType: json['linkType'] as String?,
      linkValue: json['linkValue'] as String?,
    );
  }
}
