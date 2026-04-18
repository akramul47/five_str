import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/business_model.dart';
import '../../data/repositories/business_repository.dart';
import 'location_provider.dart';
import 'repository_providers.dart';

class BusinessState {
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;
  final List<BusinessModel> businesses;
  final int currentPage;
  final bool hasMore;
  // Filters state could be added here later (category, sort, etc.)

  const BusinessState({
    this.isLoading = true,
    this.isFetchingMore = false,
    this.error,
    this.businesses = const [],
    this.currentPage = 1,
    this.hasMore = true,
  });

  BusinessState copyWith({
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    List<BusinessModel>? businesses,
    int? currentPage,
    bool? hasMore,
  }) {
    return BusinessState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: error,
      businesses: businesses ?? this.businesses,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class BusinessNotifier extends StateNotifier<BusinessState> {
  final BusinessRepository _repository;
  final Ref _ref;

  BusinessNotifier(this._repository, this._ref) : super(const BusinessState());

  Future<void> fetchBusinesses({
    bool isRefresh = false,
    int? categoryId,
    String sort = 'distance',
  }) async {
    if (isRefresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1, businesses: [], hasMore: true);
    } else if (state.isLoading || state.isFetchingMore || !state.hasMore) {
      return;
    }

    if (!isRefresh) {
      state = state.copyWith(isFetchingMore: true, error: null);
    }

    try {
      final location = _ref.read(locationProvider).apiCoordinates;
      final result = await _repository.getBusinesses(
        latitude: location.latitude,
        longitude: location.longitude,
        page: state.currentPage,
        categoryId: categoryId,
        sort: sort,
      );

      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        businesses: isRefresh ? result.items : [...state.businesses, ...result.items],
        currentPage: state.currentPage + 1,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        error: e.toString(),
      );
    }
  }
}

// A family provider allows fetching businesses parameterized by category or context if needed, 
// but for a general list, a simple provider is fine.
final businessListProvider = StateNotifierProvider.autoDispose<BusinessNotifier, BusinessState>((ref) {
  return BusinessNotifier(ref.read(businessRepositoryProvider), ref);
});
