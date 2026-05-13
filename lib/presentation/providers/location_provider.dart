import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/location_service.dart';
import 'core_providers.dart';

/// Location state exposed to the UI.
class LocationState {
  final UserLocation? location;
  final ManualLocation? manualLocation;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final int searchRadiusKm;

  const LocationState({
    this.location,
    this.manualLocation,
    this.isLoading = true,
    this.isUpdating = false,
    this.error,
    this.searchRadiusKm = 50,
  });

  LocationState copyWith({
    UserLocation? location,
    ManualLocation? manualLocation,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    int? searchRadiusKm,
    bool clearManual = false,
    bool clearError = false,
  }) {
    return LocationState(
      location: location ?? this.location,
      manualLocation:
          clearManual ? null : (manualLocation ?? this.manualLocation),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: clearError ? null : error,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
    );
  }

  /// Coordinates used for API calls: manual > GPS > Chittagong default.
  ({double latitude, double longitude}) get apiCoordinates {
    if (manualLocation != null) {
      return (
        latitude: manualLocation!.latitude,
        longitude: manualLocation!.longitude,
      );
    }
    if (location != null) {
      return (latitude: location!.latitude, longitude: location!.longitude);
    }
    return (latitude: 22.3569, longitude: 91.7832); // Chittagong default
  }

  /// Human-readable location name shown in the header.
  /// Prefers manual name → GPS nearest-district name → "Chittagong" fallback.
  String get locationName {
    if (manualLocation != null) return manualLocation!.name;
    if (location?.areaName != null) return location!.areaName!;
    return 'Chittagong';
  }

  /// Division sub-label (shown only when a district is resolved).
  String? get divisionName {
    if (manualLocation != null) return manualLocation!.division;
    if (location?.divisionName != null) return location!.divisionName;
    return null;
  }

  bool get isManual => manualLocation != null;
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(const LocationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final location = await _locationService.initialize();
      state = state.copyWith(location: location, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Request GPS update with full permission handling.
  Future<LocationUpdateResult> requestLocationUpdate() async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final result = await _locationService.requestLocationUpdate();

      if (result.success && result.location != null) {
        state = state.copyWith(
          location: result.location,
          isUpdating: false,
          clearManual: true,
        );
      } else if (result.permissionStatus ==
          LocationPermissionStatus.outsideBangladesh) {
        // Outside BD — clear manual, keep default coordinates
        state = state.copyWith(isUpdating: false, clearManual: true);
      } else {
        state = state.copyWith(isUpdating: false, error: result.message);
      }

      return result;
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
      return LocationUpdateResult(
        success: false,
        message: 'Unexpected error: $e',
        permissionStatus: LocationPermissionStatus.unknownError,
      );
    }
  }

  void setManualLocation(ManualLocation manual) {
    _locationService.setManualLocation(manual);
    state = state.copyWith(manualLocation: manual);
  }

  void clearManualLocation() {
    _locationService.clearManualLocation();
    state = state.copyWith(clearManual: true);
  }

  void setSearchRadius(int radiusKm) {
    state = state.copyWith(searchRadiusKm: radiusKm);
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref.read(locationServiceProvider));
});
