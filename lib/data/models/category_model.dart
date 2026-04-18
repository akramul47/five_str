/// Category info embedded in business responses.
class CategoryInfo {
  final int id;
  final String name;
  final String slug;

  const CategoryInfo({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
      };
}

/// Full category model (for category listings).
class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? parentId;
  final int level;
  final String? iconImage;
  final String? bannerImage;
  final String? description;
  final String colorCode;
  final int sortOrder;
  final bool isFeatured;
  final bool isPopular;
  final bool isActive;
  final int totalBusinesses;
  final List<CategoryModel>? subcategories;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.level = 1,
    this.iconImage,
    this.bannerImage,
    this.description,
    this.colorCode = '#6366F1',
    this.sortOrder = 0,
    this.isFeatured = false,
    this.isPopular = false,
    this.isActive = true,
    this.totalBusinesses = 0,
    this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      parentId: json['parent_id']?.toString(),
      level: json['level'] as int? ?? 1,
      iconImage: json['icon_image'] as String?,
      bannerImage: json['banner_image'] as String?,
      description: json['description'] as String?,
      colorCode: json['color_code'] as String? ?? '#6366F1',
      sortOrder: json['sort_order'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isPopular: json['is_popular'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      totalBusinesses: json['total_businesses'] as int? ?? 0,
      subcategories: (json['subcategories'] as List<dynamic>?)
          ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'parent_id': parentId,
        'level': level,
        'icon_image': iconImage,
        'banner_image': bannerImage,
        'description': description,
        'color_code': colorCode,
        'sort_order': sortOrder,
        'is_featured': isFeatured,
        'is_popular': isPopular,
        'is_active': isActive,
        'total_businesses': totalBusinesses,
      };
}
