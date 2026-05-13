import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/home_repository.dart';
import 'location_provider.dart';
import 'repository_providers.dart';

class HomeState {
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final HomeResponse? data;

  const HomeState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.data,
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    HomeResponse? data,
    bool clearData = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      data: clearData ? null : (data ?? this.data),
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository _repository;
  final Ref _ref;

  HomeNotifier(this._repository, this._ref) : super(const HomeState()) {
    _init();
  }

  void _init() {
    final location = _ref.read(locationProvider);
    if (!location.isLoading) {
      loadData();
    }
  }

  Future<void> loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, isLoading: true, error: null, clearData: true);
    } else {
      // Clear old data so the shimmer skeleton shows for the new location
      state = state.copyWith(isLoading: true, error: null, clearData: true);
    }

    try {
      final locationState = _ref.read(locationProvider);
      final location = locationState.apiCoordinates;
      final radius = locationState.searchRadiusKm;
      debugPrint('HomeNotifier: Loading data for ${location.latitude}, ${location.longitude} (radius: ${radius}km)');
      
      final data = await _repository.getHomeData(
        latitude: location.latitude,
        longitude: location.longitude,
        radius: radius,
      );
      
      debugPrint('HomeNotifier: Received ${data.popularNearby.length} nearby businesses');
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        data: data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.read(homeRepositoryProvider), ref);
});
