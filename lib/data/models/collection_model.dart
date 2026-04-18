/// User collection model.
class CollectionModel {
  final int id;
  final String name;
  final String? description;
  final bool isPublic;
  final String? coverImage;
  final String slug;
  final int businessesCount;
  final int followersCount;
  final String? createdAt;
  final String? updatedAt;
  final CollectionUser? user;
  final List<CollectionBusiness>? businesses;
  final bool isFollowedByUser;
  final bool canEdit;

  const CollectionModel({
    required this.id,
    required this.name,
    this.description,
    this.isPublic = true,
    this.coverImage,
    this.slug = '',
    this.businessesCount = 0,
    this.followersCount = 0,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.businesses,
    this.isFollowedByUser = false,
    this.canEdit = false,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      coverImage: json['cover_image'] as String?,
      slug: json['slug'] as String? ?? '',
      businessesCount: json['businesses_count'] as int? ?? 0,
      followersCount: json['followers_count'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      user: json['user'] != null
          ? CollectionUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      businesses: (json['businesses'] as List<dynamic>?)
          ?.map(
              (e) => CollectionBusiness.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFollowedByUser:
          json['is_followed_by_user'] as bool? ??
          json['is_following'] as bool? ??
          false,
      canEdit: json['can_edit'] as bool? ?? false,
    );
  }
}

class CollectionUser {
  final int id;
  final String name;
  final String? profileImage;

  const CollectionUser({
    required this.id,
    required this.name,
    this.profileImage,
  });

  factory CollectionUser.fromJson(Map<String, dynamic> json) {
    return CollectionUser(
      id: json['id'] as int,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
    );
  }
}

class CollectionBusiness {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? imageUrl;
  final double? rating;
  final String? categoryName;
  final String? notes;
  final int? sortOrder;
  final String? addedAt;

  const CollectionBusiness({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.imageUrl,
    this.rating,
    this.categoryName,
    this.notes,
    this.sortOrder,
    this.addedAt,
  });

  factory CollectionBusiness.fromJson(Map<String, dynamic> json) {
    return CollectionBusiness(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      categoryName: json['category_name'] as String?,
      notes: json['notes'] as String?,
      sortOrder: json['sort_order'] as int?,
      addedAt: json['added_at'] as String?,
    );
  }
}
