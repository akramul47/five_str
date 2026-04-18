import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/config/app_config.dart';

/// Location data class.
class UserLocation {
  final double latitude;
  final double longitude;
  final int timestamp;
  final String source; // 'gps', 'manual', 'default'

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.source,
  });
}

/// Manual location selection data.
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

/// GPS + manual location management service.
class LocationService {
  Position? _lastPosition;
  ManualLocation? _manualLocation;
  DateTime? _lastFetchTime;

  /// Default fallback location (Chittagong).
  static const UserLocation _defaultLocation = UserLocation(
    latitude: AppConfig.defaultLatitude,
    longitude: AppConfig.defaultLongitude,
    timestamp: 0,
    source: 'default',
  );

  /// Initialize and get the current location.
  Future<UserLocation> initialize() async {
    // DEV OVERRIDE: Hardcoding to Chittagong to guarantee the user sees local test data.
    return _defaultLocation;
  }

  /// Force refresh the GPS location.
  Future<UserLocation> refreshLocation() async {
    _manualLocation = null;
    return initialize();
  }

  /// Set a manual location (district/division selection).
  void setManualLocation(ManualLocation location) {
    _manualLocation = location;
  }

  /// Clear the manual location back to GPS/default.
  void clearManualLocation() {
    _manualLocation = null;
  }

  /// Get current manual location, if set.
  ManualLocation? get manualLocation => _manualLocation;

  /// Get coordinates for API calls, preferring manual > GPS > default.
  ({double latitude, double longitude}) getCoordinatesForAPI() {
    if (_manualLocation != null) {
      final loc = _manualLocation!;
      if (AppConfig.isInBangladesh(loc.latitude, loc.longitude)) {
        return (latitude: loc.latitude, longitude: loc.longitude);
      }
    }

    if (_lastPosition != null) {
      if (AppConfig.isInBangladesh(
          _lastPosition!.latitude, _lastPosition!.longitude)) {
        return (
          latitude: _lastPosition!.latitude,
          longitude: _lastPosition!.longitude
        );
      }
    }

    return (
      latitude: AppConfig.defaultLatitude,
      longitude: AppConfig.defaultLongitude,
    );
  }

  /// Human-readable current location info.
  ({String name, bool isManual, String? division}) getCurrentLocationInfo() {
    if (_manualLocation != null) {
      return (
        name: _manualLocation!.name,
        isManual: true,
        division: _manualLocation!.division,
      );
    }
    return (name: 'Current Location', isManual: false, division: null);
  }

  /// Age of last GPS fetch in minutes.
  int getLocationAge() {
    if (_lastFetchTime == null) return 999;
    return DateTime.now().difference(_lastFetchTime!).inMinutes;
  }
}
