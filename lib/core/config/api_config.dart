/// API configuration constants.
/// Maps to the Laravel backend endpoints.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://api.5str.xyz';
  static const String apiPrefix = '/api/v1';

  // ── Authentication ──
  static const String login = '$apiPrefix/login';
  static const String register = '$apiPrefix/register';
  static const String logout = '$apiPrefix/auth/logout';
  static const String user = '$apiPrefix/auth/user';
  static const String updateProfile = '$apiPrefix/auth/profile';

  // ── Email Verification ──
  static const String emailVerify = '$apiPrefix/email/verify';
  static const String emailResend = '$apiPrefix/email/resend';
  static const String emailStatus = '$apiPrefix/email/status';

  // ── Home & Discovery ──
  static const String home = '$apiPrefix/home';
  static const String topServices = '$apiPrefix/home/top-services';
  static const String popularNearby = '$apiPrefix/home/popular-nearby';
  static String dynamicSections(String section) =>
      '$apiPrefix/home/dynamic-sections/$section';
  static const String featuredBusinesses =
      '$apiPrefix/home/featured-businesses';
  static const String specialOffers = '$apiPrefix/home/special-offers';
  static const String nationalBrands = '$apiPrefix/home/national-brands';
  static const String featuredAttractions =
      '$apiPrefix/home/featured-attractions';
  static const String popularAttractions =
      '$apiPrefix/home/popular-attractions';
  static const String trending = '$apiPrefix/trending';
  static const String todayTrending = '$apiPrefix/today-trending';
  static const String topRated = '$apiPrefix/top-rated';
  static const String openNow = '$apiPrefix/open-now';

  // ── Search ──
  static const String search = '$apiPrefix/search';
  static const String searchSuggestions = '$apiPrefix/search/suggestions';
  static const String searchPopular = '$apiPrefix/search/popular';

  // ── Categories ──
  static const String categories = '$apiPrefix/categories';
  static String categoryDetail(int id) => '$apiPrefix/categories/$id';
  static String categoryBusinesses(int id) =>
      '$apiPrefix/categories/$id/businesses';

  // ── Businesses ──
  static const String businesses = '$apiPrefix/businesses';
  static const String businessCategories = '$apiPrefix/businesses/categories';
  static const String businessesNational = '$apiPrefix/businesses/national';
  static String businessDetail(int id) => '$apiPrefix/businesses/$id';
  static String businessReviews(int id) => '$apiPrefix/businesses/$id/reviews';
  static String businessOffers(int id) => '$apiPrefix/businesses/$id/offers';
  static String businessOfferings(int id) =>
      '$apiPrefix/businesses/$id/offerings';
  static String offeringDetail(int businessId, int offeringId) =>
      '$apiPrefix/businesses/$businessId/offerings/$offeringId';

  // ── Offers ──
  static const String offers = '$apiPrefix/offers';
  static String offerDetail(int id) => '$apiPrefix/offers/$id';

  // ── Reviews ──
  static const String reviews = '$apiPrefix/reviews';
  static String reviewDetail(int id) => '$apiPrefix/reviews/$id';
  static String reviewVote(int id) => '$apiPrefix/reviews/$id/vote';
  static String reviewVoteRemove(int id) => '$apiPrefix/reviews/$id/vote';

  // ── User ──
  static const String userFavorites = '$apiPrefix/user/favorites';
  static String removeFavorite(int id) => '$apiPrefix/user/favorites/$id';
  static const String userReviews = '$apiPrefix/user/reviews';
  static const String userPoints = '$apiPrefix/user/points';
  static String publicUserProfile(int id) => '$apiPrefix/users/$id/profile';

  // ── Notifications ──
  static const String notifications = '$apiPrefix/notifications';
  static const String notificationStats = '$apiPrefix/notifications/stats';
  static String notificationRead(String id) =>
      '$apiPrefix/notifications/$id/read';
  static const String notificationMarkAllRead =
      '$apiPrefix/notifications/mark-all-read';

  // ── Collections ──
  static const String collections = '$apiPrefix/collections';
  static String collectionDetail(int id) => '$apiPrefix/collections/$id';
  static String collectionBusinesses(int id) =>
      '$apiPrefix/collections/$id/businesses';
  static String collectionRemoveBusiness(int collectionId, int businessId) =>
      '$apiPrefix/collections/$collectionId/businesses/$businessId';
  static String collectionFollow(int id) => '$apiPrefix/collections/$id/follow';
  static const String popularCollections =
      '$apiPrefix/discover/collections/popular';
  static const String searchCollections =
      '$apiPrefix/discover/collections/search';

  // ── Recommendations ──
  static const String recommendations = '$apiPrefix/recommendations';
  static const String recommendationsAdvancedAI =
      '$apiPrefix/recommendations/advanced-ai';
  static String recommendationsSimilar(int businessId) =>
      '$apiPrefix/recommendations/similar/$businessId';

  // ── Interactions ──
  static const String trackInteraction = '$apiPrefix/interactions/track';
  static const String trackBatch = '$apiPrefix/interactions/batch';

  // ── Attractions ──
  static const String attractions = '$apiPrefix/attractions';
  static const String attractionsFeatured = '$apiPrefix/attractions/featured';
  static const String attractionsPopular = '$apiPrefix/attractions/popular';
  static String attractionDetail(int id) => '$apiPrefix/attractions/$id';
  static String attractionGallery(int id) =>
      '$apiPrefix/attractions/$id/gallery';
  static String attractionReviews(int id) =>
      '$apiPrefix/attractions/$id/reviews';

  // ── Attraction Interactions ──
  static const String attractionInteractionsToggle =
      '$apiPrefix/attraction-interactions/toggle';
  static const String attractionInteractionsRemove =
      '$apiPrefix/attraction-interactions/remove';
  static String attractionInteractionStatus(int id) =>
      '$apiPrefix/attraction-interactions/status/$id';
  static const String attractionInteractionsLiked =
      '$apiPrefix/attraction-interactions/liked';
  static const String attractionInteractionsBookmarked =
      '$apiPrefix/attraction-interactions/bookmarked';
  static const String attractionInteractionsVisited =
      '$apiPrefix/attraction-interactions/visited';

  // ── Attraction Reviews ──
  static String attractionReviewSubmit(int attractionId) =>
      '$apiPrefix/attraction-reviews/$attractionId/reviews';

  // ── Submissions ──
  static const String submitBusiness = '$apiPrefix/submissions/business';
  static const String submitAttraction = '$apiPrefix/submissions/attraction';
  static const String submitOffering = '$apiPrefix/submissions/offering';
  static const String mySubmissions = '$apiPrefix/submissions/my-submissions';
  static String submissionDetails(String type, int id) =>
      '$apiPrefix/submissions/$type/$id';

  // ── Location ──
  static const String locationRecommendations =
      '$apiPrefix/location/recommendations';

  // ── Google Auth ──
  static const String googleAuthToken = '/auth/google/token';
}
