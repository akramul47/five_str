import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/business_model.dart';
import '../../data/repositories/business_repository.dart';
import '../../data/repositories/home_repository.dart';
import 'location_provider.dart';
import 'repository_providers.dart';

// ── Section type ──────────────────────────────────────────────────────────────

/// Describes which API endpoint to hit for the business list.
class BusinessListType {
  final String slug; // unique id used as provider family key

  const BusinessListType._(this.slug);

  static const popularNearby = BusinessListType._('popular-nearby');
  static const trending      = BusinessListType._('trending');
  static const topRated      = BusinessListType._('top-rated');
  static const openNow       = BusinessListType._('open-now');

  /// Any dynamic-section slug from the home API (e.g. "top_rated", "trending_now").
  factory BusinessListType.dynamic(String sectionSlug) =>
      BusinessListType._('dynamic:$sectionSlug');

  bool get isDynamic => slug.startsWith('dynamic:');
  String get dynamicSlug => slug.replaceFirst('dynamic:', '');

  @override
  bool operator ==(Object other) =>
      other is BusinessListType && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;
}

// ── State ─────────────────────────────────────────────────────────────────────

class BusinessListState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<BusinessModel> businesses;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;
  final int totalItems;

  const BusinessListState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
    this.businesses = const [],
    this.currentPage = 1,
    this.hasMore = false,
    this.searchQuery = '',
    this.totalItems = 0,
  });

  List<BusinessModel> get filtered {
    if (searchQuery.isEmpty) return businesses;
    final q = searchQuery.toLowerCase();
    return businesses.where((b) {
      return b.businessName.toLowerCase().contains(q) ||
          (b.categoryName?.toLowerCase().contains(q) ?? false) ||
          (b.area?.toLowerCase().contains(q) ?? false) ||
          (b.city?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  BusinessListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    List<BusinessModel>? businesses,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    int? totalItems,
  }) {
    return BusinessListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      businesses: businesses ?? this.businesses,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class BusinessListNotifier extends StateNotifier<BusinessListState> {
  final BusinessRepository _businessRepo;
  final HomeRepository _homeRepo;
  final Ref _ref;
  final BusinessListType type;

  BusinessListNotifier(
    this._businessRepo,
    this._homeRepo,
    this._ref,
    this.type,
  ) : super(const BusinessListState()) {
    _loadBusinesses(reset: true);
  }

  void updateSearch(String q) {
    state = state.copyWith(searchQuery: q);
  }

  void loadMore() {
    if (state.hasMore && !state.isLoadingMore && !state.isLoading) {
      _loadBusinesses(reset: false);
    }
  }

  void refresh() => _loadBusinesses(reset: true);

  Future<void> _loadBusinesses({required bool reset}) async {
    if (!reset && (state.isLoadingMore || state.isLoading)) return;
    if (!reset && !state.hasMore) return;

    final page = reset ? 1 : state.currentPage + 1;

    if (reset) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final loc = _ref.read(locationProvider).apiCoordinates;
      final result = await _fetchPage(loc.latitude, loc.longitude, page);

      debugPrint('BusinessList [${type.slug}] page $page → '
          '${result.items.length} items | hasMore: ${result.hasMore}');

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        businesses: reset
            ? result.items
            : [...state.businesses, ...result.items],
        currentPage: result.currentPage,
        hasMore: result.hasMore,
        totalItems: result.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<PaginatedResult<BusinessModel>> _fetchPage(
    double lat,
    double lng,
    int page,
  ) async {
    const radius = 100;
    const perPage = 20;

    switch (type.slug) {
      case 'popular-nearby':
        return _businessRepo.getBusinesses(
          latitude: lat,
          longitude: lng,
          radius: radius,
          page: page,
          limit: perPage,
          sort: 'popular',
        );
      case 'trending':
        return _businessRepo.getTrending(
          latitude: lat,
          longitude: lng,
          radius: radius,
          page: page,
          limit: perPage,
        );
      case 'top-rated':
        return _businessRepo.getTopRated(
          latitude: lat,
          longitude: lng,
          radius: radius,
          page: page,
          limit: perPage,
        );
      case 'open-now':
        return _businessRepo.getOpenNow(
          latitude: lat,
          longitude: lng,
          radius: radius,
          page: page,
          limit: perPage,
        );
      default:
        if (type.isDynamic) {
          return _homeRepo.getDynamicSectionPaginated(
            slug: type.dynamicSlug,
            latitude: lat,
            longitude: lng,
            page: page,
            perPage: perPage,
          );
        }
        return PaginatedResult.empty();
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final businessListProvider = StateNotifierProvider.family<
    BusinessListNotifier, BusinessListState, BusinessListType>(
  (ref, type) => BusinessListNotifier(
    ref.read(businessRepositoryProvider),
    ref.read(homeRepositoryProvider),
    ref,
    type,
  ),
);
