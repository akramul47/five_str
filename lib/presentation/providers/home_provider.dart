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
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      data: data ?? this.data,
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
    // Listen to location changes to refresh home data
    _ref.listen<LocationState>(locationProvider, (previous, next) {
      if (previous?.apiCoordinates != next.apiCoordinates) {
        loadData(isRefresh: true);
      }
    });
    
    // Initial load
    final location = _ref.read(locationProvider);
    if (!location.isLoading) {
      loadData();
    }
  }

  Future<void> loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, error: null);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final location = _ref.read(locationProvider).apiCoordinates;
      final data = await _repository.getHomeData(
        latitude: location.latitude,
        longitude: location.longitude,
      );
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
