import 'category_model.dart';

/// Business image structure from the API.
class BusinessImages {
  final String? logo;
  final String? cover;
  final List<String>? gallery;

  const BusinessImages({this.logo, this.cover, this.gallery});

  factory BusinessImages.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return BusinessImages(
        logo: json['logo'] as String?,
        cover: json['cover'] as String?,
        gallery: (json['gallery'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );
    }
    return const BusinessImages();
  }
}

/// Business image item (from detail response images array).
class BusinessImageItem {
  final int id;
  final String imageUrl;
  final bool isLogo;

  const BusinessImageItem({
    required this.id,
    required this.imageUrl,
    this.isLogo = false,
  });

  factory BusinessImageItem.fromJson(Map<String, dynamic> json) {
    return BusinessImageItem(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      isLogo: json['is_logo'] as bool? ?? false,
    );
  }
}

/// Opening status for open-now businesses.
class OpeningStatus {
  final bool isOpen;
  final String status;
  final String nextChange;

  const OpeningStatus({
    required this.isOpen,
    required this.status,
    required this.nextChange,
  });

  factory OpeningStatus.fromJson(Map<String, dynamic> json) {
    return OpeningStatus(
      isOpen: json['is_open'] as bool? ?? false,
      status: json['status'] as String? ?? 'Unknown',
      nextChange: json['next_change'] as String? ?? '',
    );
  }
}

/// Business model for listings and cards.
class BusinessModel {
  final int id;
  final String businessName;
  final String slug;
  final String? description;
  final String? landmark;
  final String? area;
  final String? city;
  final String overallRating;
  final int priceRange;
  final int? totalReviews;
  final bool isVerified;
  final bool isFeatured;
  final String? distanceKm;
  final String? categoryName;
  final String? subcategoryName;
  final BusinessImages? images;
  final CategoryInfo? category;
  final String? type;
  final OpeningStatus? openingStatus;
  // Trending fields
  final String? trendScore;
  final int? viewCount;
  // National fields
  final bool isNational;
  final String? serviceCoverage;
  final String? businessModel;

  const BusinessModel({
    required this.id,
    required this.businessName,
    required this.slug,
    this.description,
    this.landmark,
    this.area,
    this.city,
    this.overallRating = '0',
    this.priceRange = 0,
    this.totalReviews,
    this.isVerified = false,
    this.isFeatured = false,
    this.distanceKm,
    this.categoryName,
    this.subcategoryName,
    this.images,
    this.category,
    this.type,
    this.openingStatus,
    this.trendScore,
    this.viewCount,
    this.isNational = false,
    this.serviceCoverage,
    this.businessModel,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    // Handle logo_image which can be string or object
    BusinessImages? images;
    if (json['images'] != null) {
      images = BusinessImages.fromJson(json['images']);
    } else if (json['logo_image'] != null) {
      final logo = json['logo_image'];
      images = BusinessImages(
        logo: logo is String
            ? logo
            : (logo is Map ? logo['image_url'] as String? : null),
      );
    }

    return BusinessModel(
      id: json['id'] as int,
      businessName: json['business_name'] as String,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      landmark: json['landmark'] as String?,
      area: json['area'] as String?,
      city: json['city'] as String?,
      overallRating: json['overall_rating']?.toString() ?? '0',
      priceRange: json['price_range'] as int? ?? 0,
      totalReviews: json['total_reviews'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      distanceKm: json['distance_km']?.toString() ?? json['distance']?.toString(),
      categoryName: json['category_name'] as String?,
      subcategoryName: json['subcategory_name'] as String?,
      images: images,
      category: json['category'] != null
          ? CategoryInfo.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      type: json['type'] as String?,
      openingStatus: json['opening_status'] != null
          ? OpeningStatus.fromJson(
              json['opening_status'] as Map<String, dynamic>)
          : null,
      trendScore: json['trend_score']?.toString(),
      viewCount: json['view_count'] as int?,
      isNational: json['is_national'] as bool? ?? false,
      serviceCoverage: json['service_coverage'] as String?,
      businessModel: json['business_model'] as String?,
    );
  }

  /// Get the best available logo URL.
  String? get logoUrl => images?.logo;

  /// Get the best available cover URL.
  String? get coverUrl => images?.cover;

  /// Parsed rating as double.
  double get ratingValue => double.tryParse(overallRating) ?? 0.0;
}

/// Extended business detail model (from /businesses/{id}).
class BusinessDetailModel extends BusinessModel {
  final String? businessEmail;
  final String? businessPhone;
  final String? website;
  final String? address;
  final String? postalCode;
  final String? latitude;
  final String? longitude;
  final Map<String, dynamic>? openingHours;
  final List<String>? businessFeatures;
  final Map<String, dynamic>? owner;
  final List<BusinessImageItem>? imageList;
  final int offeringsCount;
  final int offersCount;

  const BusinessDetailModel({
    required super.id,
    required super.businessName,
    required super.slug,
    super.description,
    super.area,
    super.city,
    super.overallRating = '0',
    super.priceRange = 0,
    super.totalReviews,
    super.isVerified = false,
    super.isFeatured = false,
    super.images,
    super.category,
    super.isNational = false,
    super.serviceCoverage,
    super.businessModel,
    this.businessEmail,
    this.businessPhone,
    this.website,
    this.address,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.openingHours,
    this.businessFeatures,
    this.owner,
    this.imageList,
    this.offeringsCount = 0,
    this.offersCount = 0,
  });

  factory BusinessDetailModel.fromJson(Map<String, dynamic> json) {
    final base = BusinessModel.fromJson(json);

    return BusinessDetailModel(
      id: base.id,
      businessName: base.businessName,
      slug: base.slug,
      description: base.description,
      area: base.area,
      city: base.city,
      overallRating: base.overallRating,
      priceRange: base.priceRange,
      totalReviews: base.totalReviews,
      isVerified: base.isVerified,
      isFeatured: base.isFeatured,
      images: (json['images'] is List && (json['images'] as List).isNotEmpty)
          ? BusinessImages(
              logo: (json['images'] as List).firstWhere(
                (e) => e['is_logo'] == true,
                orElse: () => (json['images'] as List).first,
              )['image_url'],
              cover: (json['images'] as List).firstWhere(
                (e) => e['is_logo'] == false,
                orElse: () => (json['images'] as List).first,
              )['image_url'],
            )
          : (json['cover_image'] != null || json['logo_image'] != null)
              ? BusinessImages(
                  cover: json['cover_image']?.toString() ?? json['logo_image']?.toString(),
                  logo: json['logo_image']?.toString() ?? json['cover_image']?.toString(),
                )
              : base.images,
      category: base.category,
      isNational: base.isNational,
      serviceCoverage: base.serviceCoverage,
      businessModel: base.businessModel,
      businessEmail: json['business_email'] as String?,
      businessPhone: json['business_phone'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      postalCode: json['postal_code'] as String?,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      openingHours: json['opening_hours'] as Map<String, dynamic>?,
      businessFeatures: (json['business_features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      owner: json['owner'] as Map<String, dynamic>?,
      imageList: (json['images'] is List)
          ? (json['images'] as List<dynamic>)
              .map((e) =>
                  BusinessImageItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      offeringsCount: json['offerings_count'] as int? ?? 0,
      offersCount: json['offers_count'] as int? ?? 0,
    );
  }
}
