/// Special offer model.
class OfferModel {
  final int id;
  final String title;
  final String? description;
  final String offerType;
  final String discountPercentage;
  final String validTo;
  final String? validUntil;
  final OfferBusiness? business;

  const OfferModel({
    required this.id,
    required this.title,
    this.description,
    this.offerType = 'percentage',
    this.discountPercentage = '0',
    required this.validTo,
    this.validUntil,
    this.business,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      offerType: json['offer_type'] as String? ?? 'percentage',
      discountPercentage: json['discount_percentage']?.toString() ?? '0',
      validTo: json['valid_to'] as String? ?? '',
      validUntil: json['valid_until'] as String?,
      business: json['business'] != null
          ? OfferBusiness.fromJson(json['business'] as Map<String, dynamic>)
          : null,
    );
  }

  double get discountValue =>
      double.tryParse(discountPercentage) ?? 0.0;
}

class OfferBusiness {
  final int id;
  final String businessName;
  final String slug;
  final String? landmark;
  final String overallRating;
  final int priceRange;
  final String? categoryName;
  final String? logoImage;

  const OfferBusiness({
    required this.id,
    required this.businessName,
    required this.slug,
    this.landmark,
    this.overallRating = '0',
    this.priceRange = 0,
    this.categoryName,
    this.logoImage,
  });

  factory OfferBusiness.fromJson(Map<String, dynamic> json) {
    return OfferBusiness(
      id: json['id'] as int,
      businessName: json['business_name'] as String,
      slug: json['slug'] as String? ?? '',
      landmark: json['landmark'] as String?,
      overallRating: json['overall_rating']?.toString() ?? '0',
      priceRange: json['price_range'] as int? ?? 0,
      categoryName: json['category_name'] as String?,
      logoImage: json['logo_image'] as String?,
    );
  }
}
