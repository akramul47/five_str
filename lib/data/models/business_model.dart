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
    // Safe parsers — API occasionally returns numeric fields as strings
    int? safeInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? safeStr(dynamic v) => v?.toString();

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
      id: safeInt(json['id']) ?? 0,
      businessName: safeStr(json['business_name']) ?? '',
      slug: safeStr(json['slug']) ?? '',
      description: safeStr(json['description']),
      landmark: safeStr(json['landmark']),
      area: safeStr(json['area']),
      city: safeStr(json['city']),
      overallRating: safeStr(json['overall_rating']) ?? '0',
      priceRange: safeInt(json['price_range']) ?? 0,
      totalReviews: safeInt(json['total_reviews']),
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      distanceKm: safeStr(json['distance_km']) ?? safeStr(json['distance']),
      categoryName: safeStr(json['category_name']),
      subcategoryName: safeStr(json['subcategory_name']),
      images: images,
      category: json['category'] != null && json['category'] is Map
          ? CategoryInfo.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      type: safeStr(json['type']),
      openingStatus: json['opening_status'] != null
          ? OpeningStatus.fromJson(
              json['opening_status'] as Map<String, dynamic>)
          : null,
      trendScore: safeStr(json['trend_score']),
      viewCount: safeInt(json['view_count']),
      isNational: json['is_national'] as bool? ?? false,
      serviceCoverage: safeStr(json['service_coverage']),
      businessModel: safeStr(json['business_model']),
    );
  }

  /// Get the best available logo URL.
  String? get logoUrl => images?.logo;

  /// Get the best available cover URL.
  String? get coverUrl => images?.cover;

  /// Parsed rating as double.
  double get ratingValue => double.tryParse(overallRating) ?? 0.0;

  /// Formatted distance to 2 decimal places.
  String? get formattedDistance {
    if (distanceKm == null || distanceKm!.isEmpty) return null;
    
    // Check if it already has a unit
    final hasUnit = distanceKm!.toLowerCase().contains('km') || 
                  distanceKm!.toLowerCase().contains('m');
    
    if (hasUnit) {
      // Try to extract number and format it
      final numberPart = distanceKm!.replaceAll(RegExp(r'[^0-9.]'), '');
      final value = double.tryParse(numberPart);
      if (value == null) return distanceKm;
      
      final unit = distanceKm!.replaceAll(RegExp(r'[0-9.]'), '').trim();
      return '${value.toStringAsFixed(2)} $unit';
    } else {
      final value = double.tryParse(distanceKm!);
      if (value == null) return distanceKm;
      return '${value.toStringAsFixed(2)} km';
    }
  }
}

/// Extended business detail model (from /businesses/{id}).
class BusinessDetailModel extends BusinessModel {
  final String? businessEmail;
  final String? businessPhone;
  final String? website;
  final String? address;
  final String? fullAddress;
  final String? googleMapsUrl;
  final Map<String, dynamic>? freeMaps;
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
    this.fullAddress,
    this.googleMapsUrl,
    this.freeMaps,
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
      fullAddress: json['full_address'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      freeMaps: json['free_maps'] as Map<String, dynamic>?,
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
