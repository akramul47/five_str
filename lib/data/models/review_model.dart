/// Review model for business/offering reviews.
class ReviewModel {
  final int id;
  final int overallRating;
  final int? serviceRating;
  final int? qualityRating;
  final int? valueRating;
  final String? title;
  final String reviewText;
  final List<String>? pros;
  final List<String>? cons;
  final String? visitDate;
  final String? amountSpent;
  final int? partySize;
  final bool isRecommended;
  final bool isVerifiedVisit;
  final int helpfulCount;
  final int notHelpfulCount;
  final String status;
  final List<ReviewImage>? images;
  final ReviewUser? user;
  final ReviewReviewable? reviewable;
  final String? createdAt;
  final String? updatedAt;

  const ReviewModel({
    required this.id,
    required this.overallRating,
    this.serviceRating,
    this.qualityRating,
    this.valueRating,
    this.title,
    required this.reviewText,
    this.pros,
    this.cons,
    this.visitDate,
    this.amountSpent,
    this.partySize,
    this.isRecommended = false,
    this.isVerifiedVisit = false,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.status = 'pending',
    this.images,
    this.user,
    this.reviewable,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      overallRating: json['overall_rating'] as int? ?? 0,
      serviceRating: json['service_rating'] as int?,
      qualityRating: json['quality_rating'] as int?,
      valueRating: json['value_rating'] as int?,
      title: json['title'] as String?,
      reviewText: json['review_text'] as String? ?? '',
      pros: (json['pros'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      cons: (json['cons'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      visitDate: json['visit_date'] as String?,
      amountSpent: json['amount_spent']?.toString(),
      partySize: json['party_size'] as int?,
      isRecommended: json['is_recommended'] as bool? ?? false,
      isVerifiedVisit: json['is_verified_visit'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      notHelpfulCount: json['not_helpful_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ReviewImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: json['user'] != null
          ? ReviewUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      reviewable: json['reviewable'] != null
          ? ReviewReviewable.fromJson(
              json['reviewable'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
}

class ReviewImage {
  final int id;
  final String imageUrl;

  const ReviewImage({required this.id, required this.imageUrl});

  factory ReviewImage.fromJson(Map<String, dynamic> json) {
    return ReviewImage(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
    );
  }
}

class ReviewUser {
  final int id;
  final String name;
  final String? profileImage;
  final int trustLevel;

  const ReviewUser({
    required this.id,
    required this.name,
    this.profileImage,
    this.trustLevel = 0,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id'] as int,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
      trustLevel: json['trust_level'] as int? ?? 0,
    );
  }
}

class ReviewReviewable {
  final String type;
  final int id;
  final String? businessName;
  final String? slug;
  final String? categoryName;
  final String? logoImage;

  const ReviewReviewable({
    required this.type,
    required this.id,
    this.businessName,
    this.slug,
    this.categoryName,
    this.logoImage,
  });

  factory ReviewReviewable.fromJson(Map<String, dynamic> json) {
    return ReviewReviewable(
      type: json['type'] as String? ?? 'business',
      id: json['id'] as int,
      businessName: json['business_name'] as String?,
      slug: json['slug'] as String?,
      categoryName: json['category_name'] as String?,
      logoImage: json['logo_image'] as String?,
    );
  }
}
