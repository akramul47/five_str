import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/business_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/business_repository.dart';
import 'location_provider.dart';
import 'repository_providers.dart';

// ── Category State ────────────────────────────────────────────────────────────

class CategoryState {
  final bool isLoadingCategory;
  final bool isLoadingBusinesses;
  final bool isLoadingMore;
  final String? error;

  final CategoryModel? category;
  final List<BusinessModel> businesses;
  final int? selectedSubcategoryId;
  final String sort;

  final int currentPage;
  final bool hasMore;

  const CategoryState({
    this.isLoadingCategory = true,
    this.isLoadingBusinesses = true,
    this.isLoadingMore = false,
    this.error,
    this.category,
    this.businesses = const [],
    this.selectedSubcategoryId,
    this.sort = 'distance',
    this.currentPage = 1,
    this.hasMore = false,
  });

  CategoryState copyWith({
    bool? isLoadingCategory,
    bool? isLoadingBusinesses,
    bool? isLoadingMore,
    String? error,
    CategoryModel? category,
    List<BusinessModel>? businesses,
    int? selectedSubcategoryId,
    bool clearSubcategory = false,
    String? sort,
    int? currentPage,
    bool? hasMore,
  }) {
    return CategoryState(
      isLoadingCategory: isLoadingCategory ?? this.isLoadingCategory,
      isLoadingBusinesses: isLoadingBusinesses ?? this.isLoadingBusinesses,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      category: category ?? this.category,
      businesses: businesses ?? this.businesses,
      selectedSubcategoryId: clearSubcategory
          ? null
          : (selectedSubcategoryId ?? this.selectedSubcategoryId),
      sort: sort ?? this.sort,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ── Category Notifier ─────────────────────────────────────────────────────────

class CategoryNotifier extends StateNotifier<CategoryState> {
  final BusinessRepository _repository;
  final Ref _ref;
  final int categoryId;

  CategoryNotifier(this._repository, this._ref, this.categoryId)
      : super(const CategoryState()) {
    _init();
  }

  void _init() {
    _loadCategory();
    _loadBusinesses(reset: true);
  }

  Future<void> _loadCategory() async {
    try {
      final category = await _repository.getCategoryDetail(categoryId);
      state = state.copyWith(category: category, isLoadingCategory: false);
    } catch (e) {
      state = state.copyWith(isLoadingCategory: false, error: e.toString());
    }
  }

  Future<void> _loadBusinesses({bool reset = false}) async {
    // Guard: don't fire if already fetching a next page
    if (!reset && (state.isLoadingMore || state.isLoadingBusinesses)) return;
    // Guard: no more pages to load
    if (!reset && !state.hasMore) return;

    final page = reset ? 1 : state.currentPage + 1;
    final targetId = state.selectedSubcategoryId ?? categoryId;

    if (reset) {
      state = state.copyWith(isLoadingBusinesses: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final location = _ref.read(locationProvider).apiCoordinates;
      final result = await _repository.getByCategory(
        categoryId: targetId,
        latitude: location.latitude,
        longitude: location.longitude,
        radius: 100, // Wide radius for browse/discovery — nearest first via sort
        page: page,
        sort: state.sort,
      );

      state = state.copyWith(
        isLoadingBusinesses: false,
        isLoadingMore: false,
        businesses: reset ? result.items : [...state.businesses, ...result.items],
        currentPage: result.currentPage,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingBusinesses: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void selectSubcategory(int? subcategoryId) {
    if (state.selectedSubcategoryId == subcategoryId) return;
    state = state.copyWith(
      selectedSubcategoryId: subcategoryId,
      clearSubcategory: subcategoryId == null,
    );
    _loadBusinesses(reset: true);
  }

  void changeSort(String sort) {
    if (state.sort == sort) return;
    state = state.copyWith(sort: sort);
    _loadBusinesses(reset: true);
  }

  void loadMore() {
    if (state.hasMore && !state.isLoadingMore && !state.isLoadingBusinesses) {
      _loadBusinesses(reset: false);
    }
  }

  void refresh() {
    _loadBusinesses(reset: true);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final categoryProvider = StateNotifierProvider.family<CategoryNotifier,
    CategoryState, int>((ref, categoryId) {
  return CategoryNotifier(
    ref.read(businessRepositoryProvider),
    ref,
    categoryId,
  );
});
