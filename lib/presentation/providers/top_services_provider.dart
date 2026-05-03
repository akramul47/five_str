import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/home_repository.dart';
import 'home_provider.dart';
import 'location_provider.dart';
import 'repository_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class TopServicesState {
  final bool isLoading;
  final String? error;
  final List<CategoryModel> categories;
  final String searchQuery;

  const TopServicesState({
    this.isLoading = true,
    this.error,
    this.categories = const [],
    this.searchQuery = '',
  });

  TopServicesState copyWith({
    bool? isLoading,
    String? error,
    List<CategoryModel>? categories,
    String? searchQuery,
  }) {
    return TopServicesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Returns categories filtered by the current search query.
  List<CategoryModel> get filteredCategories {
    if (searchQuery.isEmpty) return categories;
    final q = searchQuery.toLowerCase();
    return categories
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class TopServicesNotifier extends StateNotifier<TopServicesState> {
  final HomeRepository _repository;
  final Ref _ref;

  TopServicesNotifier(this._repository, this._ref)
      : super(const TopServicesState()) {
    _init();
  }

  void _init() {
    // ── Fast path: reuse data already in homeProvider ──
    final homeData = _ref.read(homeProvider).data;
    if (homeData != null && homeData.topServices.isNotEmpty) {
      debugPrint('══════════════════════════════════════════════════════════');
      debugPrint('TOP SERVICES — seeded from homeProvider (no extra API call)');
      debugPrint('Total categories: ${homeData.topServices.length}');
      for (final cat in homeData.topServices) {
        debugPrint(
          '  [${cat.id}] ${cat.name} | businesses: ${cat.totalBusinesses} | '
          'featured: ${cat.isFeatured} | popular: ${cat.isPopular} | '
          'color: ${cat.colorCode}',
        );
      }
      debugPrint('══════════════════════════════════════════════════════════');
      state = state.copyWith(isLoading: false, categories: homeData.topServices);
      return;
    }

    // ── Slow path: fetch from dedicated endpoint ──
    load();
  }

  Future<void> load({bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final location = _ref.read(locationProvider).apiCoordinates;
      final categories = await _repository.getTopServicesWithLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      state = state.copyWith(isLoading: false, categories: categories);
    } catch (e) {
      debugPrint('TOP SERVICES ERROR: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final topServicesProvider =
    StateNotifierProvider<TopServicesNotifier, TopServicesState>((ref) {
  return TopServicesNotifier(ref.read(homeRepositoryProvider), ref);
});
