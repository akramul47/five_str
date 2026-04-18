/// Banner model for home carousels.
class BannerModel {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String linkType;
  final int? linkId;
  final String? linkUrl;
  final String position;
  final bool isActive;
  final int sortOrder;

  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.linkType = 'none',
    this.linkId,
    this.linkUrl,
    this.position = 'home_top',
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String? ?? '',
      linkType: json['link_type'] as String? ?? 'none',
      linkId: json['link_id'] as int?,
      linkUrl: json['link_url'] as String?,
      position: json['position'] as String? ?? 'home_top',
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
