/// Attraction model for listings.
class AttractionModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String type;
  final String category;
  final String? subcategory;
  final String city;
  final String? area;
  final String? district;
  final bool isFree;
  final String entryFee;
  final String currency;
  final String overallRating;
  final int totalReviews;
  final int totalViews;
  final String? discoveryScore;
  final int estimatedDurationMinutes;
  final String difficultyLevel;
  final String? coverImageUrl;
  final String? googleMapsUrl;
  final double? distance;
  final List<String> facilities;
  final Map<String, dynamic>? bestTimeToVisit;
  final bool isFeatured;
  final bool isVerified;
  final int? recentReviewsCount;

  const AttractionModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.type = 'natural',
    this.category = '',
    this.subcategory,
    this.city = '',
    this.area,
    this.district,
    this.isFree = false,
    this.entryFee = '0',
    this.currency = 'BDT',
    this.overallRating = '0',
    this.totalReviews = 0,
    this.totalViews = 0,
    this.discoveryScore,
    this.estimatedDurationMinutes = 0,
    this.difficultyLevel = 'easy',
    this.coverImageUrl,
    this.googleMapsUrl,
    this.distance,
    this.facilities = const [],
    this.bestTimeToVisit,
    this.isFeatured = false,
    this.isVerified = false,
    this.recentReviewsCount,
  });

  factory AttractionModel.fromJson(Map<String, dynamic> json) {
    int? safeInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    // Parse facilities which can be a string (JSON) or a list
    List<String> parseFacilities(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return AttractionModel(
      id: safeInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'natural',
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String?,
      city: json['city'] as String? ?? '',
      area: json['area'] as String?,
      district: json['district'] as String?,
      isFree: json['is_free'] as bool? ?? false,
      entryFee: json['entry_fee']?.toString() ?? '0',
      currency: json['currency'] as String? ?? 'BDT',
      overallRating: json['overall_rating']?.toString() ?? '0',
      totalReviews: safeInt(json['total_reviews']) ?? 0,
      totalViews: safeInt(json['total_views']) ?? 0,
      discoveryScore: json['discovery_score']?.toString(),
      estimatedDurationMinutes: safeInt(json['estimated_duration_minutes']) ?? 0,
      difficultyLevel: json['difficulty_level'] as String? ?? 'easy',
      coverImageUrl: json['cover_image_url'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      distance: (json['distance_km'] as num?)?.toDouble() ??
          (json['distance'] as num?)?.toDouble(),
      facilities: parseFacilities(json['facilities']),
      bestTimeToVisit: json['best_time_to_visit'] is Map
          ? json['best_time_to_visit'] as Map<String, dynamic>
          : null,
      isFeatured: json['is_featured'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      recentReviewsCount: safeInt(json['recent_reviews_count']),
    );
  }

  double get ratingValue => double.tryParse(overallRating) ?? 0.0;
  double get entryFeeValue => double.tryParse(entryFee) ?? 0.0;

  /// Formatted distance to 2 decimal places.
  String? get formattedDistance {
    if (distance == null) return null;
    return '${distance!.toStringAsFixed(2)} km';
  }
}
