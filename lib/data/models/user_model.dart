/// User level information from the backend.
class UserLevel {
  final int level;
  final String levelName;
  final String levelDescription;
  final double totalScore;
  final double progressToNextLevel;
  final double pointsContribution;
  final double activityContribution;
  final double trustContribution;
  final int nextLevelThreshold;

  const UserLevel({
    required this.level,
    required this.levelName,
    required this.levelDescription,
    required this.totalScore,
    required this.progressToNextLevel,
    required this.pointsContribution,
    required this.activityContribution,
    required this.trustContribution,
    required this.nextLevelThreshold,
  });

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      level: json['level'] as int? ?? 1,
      levelName: json['level_name'] as String? ?? 'New Explorer',
      levelDescription: json['level_description'] as String? ?? '',
      totalScore: (json['total_score'] as num?)?.toDouble() ?? 0,
      progressToNextLevel:
          (json['progress_to_next_level'] as num?)?.toDouble() ?? 0,
      pointsContribution:
          (json['points_contribution'] as num?)?.toDouble() ?? 0,
      activityContribution:
          (json['activity_contribution'] as num?)?.toDouble() ?? 0,
      trustContribution:
          (json['trust_contribution'] as num?)?.toDouble() ?? 0,
      nextLevelThreshold: json['next_level_threshold'] as int? ?? 40,
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'level_name': levelName,
        'level_description': levelDescription,
        'total_score': totalScore,
        'progress_to_next_level': progressToNextLevel,
        'points_contribution': pointsContribution,
        'activity_contribution': activityContribution,
        'trust_contribution': trustContribution,
        'next_level_threshold': nextLevelThreshold,
      };
}

/// Authenticated user model.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? city;
  final String? profileImage;
  final String? currentLatitude;
  final String? currentLongitude;
  final int trustLevel;
  final int totalPoints;
  final int totalFavorites;
  final int totalReviews;
  final UserLevel? userLevel;
  final bool isActive;
  final List<String> roles;
  final String? emailVerifiedAt;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.city,
    this.profileImage,
    this.currentLatitude,
    this.currentLongitude,
    this.trustLevel = 0,
    this.totalPoints = 0,
    this.totalFavorites = 0,
    this.totalReviews = 0,
    this.userLevel,
    this.isActive = true,
    this.roles = const ['user'],
    this.emailVerifiedAt,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      profileImage: json['profile_image'] as String?,
      currentLatitude: json['current_latitude']?.toString(),
      currentLongitude: json['current_longitude']?.toString(),
      trustLevel: json['trust_level'] as int? ?? 0,
      totalPoints: json['total_points'] as int? ?? 0,
      totalFavorites: json['total_favorites'] as int? ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      userLevel: json['user_level'] != null
          ? UserLevel.fromJson(json['user_level'] as Map<String, dynamic>)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['user'],
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'profile_image': profileImage,
        'current_latitude': currentLatitude,
        'current_longitude': currentLongitude,
        'trust_level': trustLevel,
        'total_points': totalPoints,
        'total_favorites': totalFavorites,
        'total_reviews': totalReviews,
        'user_level': userLevel?.toJson(),
        'is_active': isActive,
        'roles': roles,
        'email_verified_at': emailVerifiedAt,
        'created_at': createdAt,
      };

  bool get isEmailVerified => emailVerifiedAt != null;
}
