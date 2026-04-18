/// Offering (product/service) model.
class OfferingModel {
  final int id;
  final String name;
  final String? description;
  final String offeringType;
  final String price;
  final String? priceMax;
  final String currency;
  final String? imageUrl;
  final bool isAvailable;
  final bool isPopular;
  final bool isFeatured;
  final String averageRating;
  final int totalReviews;
  final OfferingBusiness? business;
  final List<OfferingVariant>? variants;
  final String? type;

  const OfferingModel({
    required this.id,
    required this.name,
    this.description,
    this.offeringType = 'product',
    this.price = '0',
    this.priceMax,
    this.currency = 'BDT',
    this.imageUrl,
    this.isAvailable = true,
    this.isPopular = false,
    this.isFeatured = false,
    this.averageRating = '0',
    this.totalReviews = 0,
    this.business,
    this.variants,
    this.type,
  });

  factory OfferingModel.fromJson(Map<String, dynamic> json) {
    return OfferingModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? json['offering_name'] as String? ?? '',
      description: json['description'] as String?,
      offeringType: json['offering_type'] as String? ?? 'product',
      price: json['price']?.toString() ?? '0',
      priceMax: json['price_max']?.toString(),
      currency: json['currency'] as String? ?? 'BDT',
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      isPopular: json['is_popular'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      averageRating: json['average_rating']?.toString() ?? '0',
      totalReviews: json['total_reviews'] as int? ?? 0,
      business: json['business'] != null
          ? OfferingBusiness.fromJson(json['business'] as Map<String, dynamic>)
          : null,
      variants: (json['variants'] as List<dynamic>?)
          ?.map((v) => OfferingVariant.fromJson(v as Map<String, dynamic>))
          .toList(),
      type: json['type'] as String?,
    );
  }

  double get ratingValue => double.tryParse(averageRating) ?? 0.0;
  double get priceValue => double.tryParse(price) ?? 0.0;
}

class OfferingBusiness {
  final int id;
  final String businessName;
  final String slug;
  final String? city;
  final String? area;
  final double? distanceKm;

  const OfferingBusiness({
    required this.id,
    required this.businessName,
    required this.slug,
    this.city,
    this.area,
    this.distanceKm,
  });

  factory OfferingBusiness.fromJson(Map<String, dynamic> json) {
    return OfferingBusiness(
      id: json['id'] as int,
      businessName: json['business_name'] as String,
      slug: json['slug'] as String? ?? '',
      city: json['city'] as String?,
      area: json['area'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }
}

class OfferingVariant {
  final int id;
  final String variantName;
  final String price;

  const OfferingVariant({
    required this.id,
    required this.variantName,
    required this.price,
  });

  factory OfferingVariant.fromJson(Map<String, dynamic> json) {
    return OfferingVariant(
      id: json['id'] as int,
      variantName: json['variant_name'] as String,
      price: json['price']?.toString() ?? '0',
    );
  }
}
