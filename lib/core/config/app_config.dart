/// App-wide constants and configuration values.
class AppConfig {
  AppConfig._();

  static const String appName = '5STR';
  static const String appFullName = '5STR Business Discovery Platform';
  static const String packageName = 'com.fivestr.app';

  // Default location: Chittagong, Bangladesh
  static const double defaultLatitude = 22.3569;
  static const double defaultLongitude = 91.7832;
  static const int defaultRadiusKm = 10;

  // Bangladesh geographic bounds
  static const double bdMinLat = 20.670883;
  static const double bdMaxLat = 26.631945;
  static const double bdMinLng = 88.028336;
  static const double bdMaxLng = 92.673668;

  // Pagination defaults
  static const int defaultPageSize = 20;

  // Search
  static const int searchDebounceMs = 400;
  static const int minSearchChars = 2;

  // Cache durations (in minutes)
  static const int homeCacheDuration = 5;
  static const int categoryCacheDuration = 30;

  // Image upload
  static const int maxReviewImages = 5;
  static const int maxImageSizeMB = 5;

  // User levels
  static const Map<int, String> userLevels = {
    0: 'New Explorer',
    40: 'Rising Contributor',
    80: 'Active Explorer',
    120: 'Seasoned Reviewer',
    150: 'Expert Explorer',
  };

  /// Check if coordinates are within Bangladesh.
  static bool isInBangladesh(double lat, double lng) {
    return lat >= bdMinLat &&
        lat <= bdMaxLat &&
        lng >= bdMinLng &&
        lng <= bdMaxLng;
  }
}
