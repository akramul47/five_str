import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/config/app_config.dart';

// ─── Bangladesh districts for nearest-match lookup ────────────────────────────

class _District {
  final String name;
  final double latitude;
  final double longitude;
  final String division;
  const _District(this.name, this.latitude, this.longitude, this.division);
}

const List<_District> _districts = [
  _District('Dhaka',          23.8103, 90.4125, 'Dhaka'),
  _District('Chittagong',     22.3569, 91.7832, 'Chittagong'),
  _District('Sylhet',         24.8949, 91.8687, 'Sylhet'),
  _District('Rajshahi',       24.3745, 88.6042, 'Rajshahi'),
  _District('Khulna',         22.8456, 89.5403, 'Khulna'),
  _District('Barisal',        22.7010, 90.3535, 'Barisal'),
  _District('Rangpur',        25.7439, 89.2752, 'Rangpur'),
  _District('Mymensingh',     24.7471, 90.4203, 'Mymensingh'),
  _District('Comilla',        23.4682, 91.1788, 'Chittagong'),
  _District('Gazipur',        23.9999, 90.4203, 'Dhaka'),
  _District('Narayanganj',    23.6238, 90.4990, 'Dhaka'),
  _District('Bogra',          24.8465, 89.3775, 'Rajshahi'),
  _District('Jessore',        23.1695, 89.2134, 'Khulna'),
  _District('Dinajpur',       25.6217, 88.6354, 'Rangpur'),
  _District('Kushtia',        23.9013, 89.1206, 'Khulna'),
  _District('Pabna',          24.0064, 89.2372, 'Rajshahi'),
  _District('Tangail',        24.2513, 89.9167, 'Dhaka'),
  _District('Faridpur',       23.6070, 89.8429, 'Dhaka'),
  _District('Brahmanbaria',   23.9571, 91.1115, 'Chittagong'),
  _District('Noakhali',       22.8696, 91.0995, 'Chittagong'),
  _District('Feni',           23.0159, 91.3976, 'Chittagong'),
  _District('Lakshmipur',     22.9447, 90.8282, 'Chittagong'),
  _District("Cox's Bazar",    21.4272, 92.0058, 'Chittagong'),
  _District('Rangamati',      22.6533, 92.1734, 'Chittagong'),
  _District('Bandarban',      22.1953, 92.2183, 'Chittagong'),
  _District('Khagrachhari',   23.1193, 91.9847, 'Chittagong'),
  _District('Chandpur',       23.2332, 90.6712, 'Chittagong'),
  _District('Moulvibazar',    24.4829, 91.7774, 'Sylhet'),
  _District('Habiganj',       24.3745, 91.4156, 'Sylhet'),
  _District('Sunamganj',      25.0658, 91.3950, 'Sylhet'),
  _District('Narsingdi',      23.9322, 90.7151, 'Dhaka'),
  _District('Manikganj',      23.8644, 90.0047, 'Dhaka'),
  _District('Munshiganj',     23.5422, 90.5305, 'Dhaka'),
  _District('Rajbari',        23.7574, 89.6444, 'Dhaka'),
  _District('Madaripur',      23.1641, 90.1896, 'Dhaka'),
  _District('Gopalganj',      23.0488, 89.8266, 'Dhaka'),
  _District('Shariatpur',     23.2422, 90.4348, 'Dhaka'),
  _District('Kishoreganj',    24.4449, 90.7760, 'Dhaka'),
  _District('Netrokona',      24.8807, 90.7279, 'Mymensingh'),
  _District('Sherpur',        25.0204, 90.0174, 'Mymensingh'),
  _District('Jamalpur',       24.9375, 89.9370, 'Mymensingh'),
  _District('Sirajganj',      24.4533, 89.7006, 'Rajshahi'),
  _District('Natore',         24.4206, 89.0015, 'Rajshahi'),
  _District('Joypurhat',      25.0968, 89.0227, 'Rajshahi'),
  _District('Chapainawabganj',24.5965, 88.2775, 'Rajshahi'),
  _District('Naogaon',        24.7936, 88.9318, 'Rajshahi'),
  _District('Satkhira',       22.7185, 89.0705, 'Khulna'),
  _District('Bagerhat',       22.6602, 89.7895, 'Khulna'),
  _District('Narail',         23.1728, 89.5126, 'Khulna'),
  _District('Chuadanga',      23.6401, 88.8412, 'Khulna'),
  _District('Meherpur',       23.7627, 88.6318, 'Khulna'),
  _District('Magura',         23.4855, 89.4198, 'Khulna'),
  _District('Jhenaidah',      23.5449, 89.1539, 'Khulna'),
  _District('Pirojpur',       22.5841, 89.9720, 'Barisal'),
  _District('Jhalokati',      22.6406, 90.1987, 'Barisal'),
  _District('Patuakhali',     22.3596, 90.3298, 'Barisal'),
  _District('Barguna',        22.1596, 90.1115, 'Barisal'),
  _District('Bhola',          22.6859, 90.6482, 'Barisal'),
  _District('Kurigram',       25.8055, 89.6361, 'Rangpur'),
  _District('Lalmonirhat',    25.9923, 89.2847, 'Rangpur'),
  _District('Nilphamari',     25.9310, 88.8563, 'Rangpur'),
  _District('Gaibandha',      25.3287, 89.5280, 'Rangpur'),
  _District('Thakurgaon',     26.0336, 88.4616, 'Rangpur'),
  _District('Panchagarh',     26.3411, 88.5541, 'Rangpur'),
];

/// Returns the name and division of the nearest district to [lat]/[lng].
({String name, String division}) nearestDistrict(double lat, double lng) {
  _District? best;
  double bestDist = double.infinity;
  for (final d in _districts) {
    final dist = _haversine(lat, lng, d.latitude, d.longitude);
    if (dist < bestDist) {
      bestDist = dist;
      best = d;
    }
  }
  // Should never be null given the non-empty list, but guard anyway
  return (name: best?.name ?? 'Chittagong', division: best?.division ?? 'Chittagong');
}

double _haversine(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _rad(double deg) => deg * pi / 180;

// ─── Data classes ─────────────────────────────────────────────────────────────

/// GPS location data.
class UserLocation {
  final double latitude;
  final double longitude;
  final int timestamp;
  final String source; // 'gps' | 'manual' | 'default'
  /// Human-readable area name derived from nearest-district lookup.
  final String? areaName;
  final String? divisionName;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.source,
    this.areaName,
    this.divisionName,
  });
}

/// Manual location selection (district / city).
class ManualLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String? division;

  const ManualLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.division,
  });
}

/// Result from a location permission + GPS request.
class LocationUpdateResult {
  final bool success;
  final UserLocation? location;
  final String message;
  final LocationPermissionStatus permissionStatus;

  const LocationUpdateResult({
    required this.success,
    this.location,
    required this.message,
    required this.permissionStatus,
  });
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  outsideBangladesh,
  timeout,
  unknownError,
}

// ─── Service ──────────────────────────────────────────────────────────────────

/// GPS + manual location management service.
class LocationService {
  Position? _lastPosition;
  ManualLocation? _manualLocation;
  DateTime? _lastFetchTime;

  static const _highAccuracy   = LocationSettings(accuracy: LocationAccuracy.high);
  static const _mediumAccuracy = LocationSettings(accuracy: LocationAccuracy.medium);

  /// Default fallback: Chittagong.
  static UserLocation get _defaultLocation {
    final nd = nearestDistrict(AppConfig.defaultLatitude, AppConfig.defaultLongitude);
    return UserLocation(
      latitude: AppConfig.defaultLatitude,
      longitude: AppConfig.defaultLongitude,
      timestamp: 0,
      source: 'default',
      areaName: nd.name,
      divisionName: nd.division,
    );
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Initialise: silently tries GPS, falls back to Chittagong default.
  Future<UserLocation> initialize() async {
    try {
      return await _tryGetGpsLocation() ?? _defaultLocation;
    } catch (_) {
      return _defaultLocation;
    }
  }

  /// Request GPS update with full permission handling and descriptive errors.
  Future<LocationUpdateResult> requestLocationUpdate() async {
    // 1. Service enabled?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationUpdateResult(
        success: false,
        message: 'Location services are disabled. Please turn on GPS in device settings.',
        permissionStatus: LocationPermissionStatus.serviceDisabled,
      );
    }

    // 2. Permission check / request
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return const LocationUpdateResult(
        success: false,
        message: 'Location permission denied. Please allow location access when prompted.',
        permissionStatus: LocationPermissionStatus.denied,
      );
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationUpdateResult(
        success: false,
        message:
            'Location permission is permanently denied. '
            'Go to App Settings → Permissions → Location and allow access.',
        permissionStatus: LocationPermissionStatus.deniedForever,
      );
    }

    // 3. Fetch position
    try {
      final position = await _fetchPosition();

      // 4. Bangladesh bounds check
      if (!AppConfig.isInBangladesh(position.latitude, position.longitude)) {
        return LocationUpdateResult(
          success: false,
          location: _defaultLocation,
          message:
              'Your GPS location is outside Bangladesh. '
              'Defaulted to Chittagong. You can select a district manually.',
          permissionStatus: LocationPermissionStatus.outsideBangladesh,
        );
      }

      _lastPosition = position;
      _lastFetchTime = DateTime.now();

      final nd = nearestDistrict(position.latitude, position.longitude);
      debugPrint('LocationService: GPS Resolved to ${nd.name} (${position.latitude}, ${position.longitude})');
      
      final gpsLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        source: 'gps',
        areaName: nd.name,
        divisionName: nd.division,
      );

      return LocationUpdateResult(
        success: true,
        location: gpsLocation,
        message: 'Location updated successfully.',
        permissionStatus: LocationPermissionStatus.granted,
      );
    } on _LocationTimeoutException {
      return const LocationUpdateResult(
        success: false,
        message:
            'Location request timed out. Ensure GPS is on and you have a clear '
            'view of the sky, then try again.',
        permissionStatus: LocationPermissionStatus.timeout,
      );
    } on LocationServiceDisabledException {
      return const LocationUpdateResult(
        success: false,
        message: 'GPS was turned off. Please enable location services and try again.',
        permissionStatus: LocationPermissionStatus.serviceDisabled,
      );
    } on PermissionDeniedException {
      return const LocationUpdateResult(
        success: false,
        message: 'Location permission was revoked. Please allow it in app settings.',
        permissionStatus: LocationPermissionStatus.denied,
      );
    } catch (e) {
      return LocationUpdateResult(
        success: false,
        message: 'Location error (${e.runtimeType}). Please try again.',
        permissionStatus: LocationPermissionStatus.unknownError,
      );
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// High accuracy (20 s) → medium accuracy (15 s) fallback.
  Future<Position> _fetchPosition() async {
    // 1. Try last known position first (instant)
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null &&
        AppConfig.isInBangladesh(lastKnown.latitude, lastKnown.longitude)) {
      // If it's reasonably fresh (last 5 mins), return it immediately
      // This prevents unnecessary waiting on first boot
      final age = DateTime.now().difference(lastKnown.timestamp).inMinutes;
      if (age < 5) {
        debugPrint('LocationService: Using fresh cached position (Age: $age min)');
        return lastKnown;
      }
    }

    // 2. Try fresh High Accuracy fix
    try {
      debugPrint('LocationService: Requesting High Accuracy fix...');
      return await Geolocator.getCurrentPosition(
        locationSettings: _highAccuracy,
      ).timeout(
        const Duration(seconds: 25), // Increased for cold fixes
      );
    } catch (e) {
      debugPrint('LocationService: High Accuracy failed/timed out ($e). Falling back to Medium...');
    }

    // 3. Fallback to Medium Accuracy fix
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: _mediumAccuracy,
      ).timeout(
        const Duration(seconds: 15), // Increased for reliability
      );
    } catch (e) {
      debugPrint('LocationService: Medium Accuracy also failed ($e).');
      throw const _LocationTimeoutException();
    }
  }

  /// Silent GPS attempt during app init — no prompts, no errors.
  Future<UserLocation?> _tryGetGpsLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // 1. Try last known position first (instant)
      Position? position = await Geolocator.getLastKnownPosition();

      // 2. If no last known or it's old/outside, try a quick fresh fetch
      if (position == null ||
          !AppConfig.isInBangladesh(position.latitude, position.longitude)) {
        position = await Geolocator.getCurrentPosition(
          locationSettings: _mediumAccuracy, // Medium is faster than High for first fix
        ).timeout(const Duration(seconds: 5));
      }

      if (!AppConfig.isInBangladesh(position.latitude, position.longitude)) {
        return null;
      }

      _lastPosition = position;
      _lastFetchTime = DateTime.now();

      final nd = nearestDistrict(position.latitude, position.longitude);
      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        source: 'gps',
        areaName: nd.name,
        divisionName: nd.division,
      );
    } catch (_) {
      return null;
    }
  }

  Future<UserLocation> refreshLocation() async {
    _manualLocation = null;
    return initialize();
  }

  void setManualLocation(ManualLocation location) => _manualLocation = location;
  void clearManualLocation() => _manualLocation = null;
  ManualLocation? get manualLocation => _manualLocation;

  ({double latitude, double longitude}) getCoordinatesForAPI() {
    if (_manualLocation != null &&
        AppConfig.isInBangladesh(
            _manualLocation!.latitude, _manualLocation!.longitude)) {
      return (latitude: _manualLocation!.latitude, longitude: _manualLocation!.longitude);
    }
    if (_lastPosition != null &&
        AppConfig.isInBangladesh(
            _lastPosition!.latitude, _lastPosition!.longitude)) {
      return (latitude: _lastPosition!.latitude, longitude: _lastPosition!.longitude);
    }
    return (latitude: AppConfig.defaultLatitude, longitude: AppConfig.defaultLongitude);
  }

  int getLocationAge() {
    if (_lastFetchTime == null) return 999;
    return DateTime.now().difference(_lastFetchTime!).inMinutes;
  }
}

class _LocationTimeoutException implements Exception {
  const _LocationTimeoutException();
}
