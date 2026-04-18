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

  const LocationState({
    this.location,
    this.manualLocation,
    this.isLoading = true,
    this.isUpdating = false,
    this.error,
  });

  LocationState copyWith({
    UserLocation? location,
    ManualLocation? manualLocation,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    bool clearManual = false,
  }) {
    return LocationState(
      location: location ?? this.location,
      manualLocation: clearManual ? null : (manualLocation ?? this.manualLocation),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
    );
  }

  /// Get coordinates for API calls (manual > GPS > default).
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

  /// Human-readable location name.
  String get locationName {
    if (manualLocation != null) return manualLocation!.name;
    return 'Current Location';
  }

  bool get isManual => manualLocation != null;
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationNotifier(this._locationService)
      : super(const LocationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final location = await _locationService.initialize();
      state = state.copyWith(location: location, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get location',
      );
    }
  }

  /// Force refresh GPS.
  Future<void> refreshLocation() async {
    state = state.copyWith(isUpdating: true, clearManual: true);
    try {
      final location = await _locationService.refreshLocation();
      state = state.copyWith(location: location, isUpdating: false);
    } catch (e) {
      state = state.copyWith(isUpdating: false);
    }
  }

  /// Set manual location (district picker).
  void setManualLocation(ManualLocation manual) {
    _locationService.setManualLocation(manual);
    state = state.copyWith(manualLocation: manual);
  }

  /// Clear manual location, revert to GPS.
  void clearManualLocation() {
    _locationService.clearManualLocation();
    state = state.copyWith(clearManual: true);
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref.read(locationServiceProvider));
});
