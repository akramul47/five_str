import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/business_model.dart';
import '../../../data/models/offering_model.dart';
import '../../../data/models/review_model.dart';
import 'repository_providers.dart';

class BusinessDetailState {
  final BusinessDetailModel? detail;
  final List<OfferingModel> offerings;
  final List<ReviewModel> reviews;
  final bool isLoadingDetail;
  final bool isLoadingOfferings;
  final bool isLoadingReviews;
  final String? error;

  const BusinessDetailState({
    this.detail,
    this.offerings = const [],
    this.reviews = const [],
    this.isLoadingDetail = false,
    this.isLoadingOfferings = false,
    this.isLoadingReviews = false,
    this.error,
  });

  /// Backward-compat shim used by the loading gate in the screen.
  bool get isLoading => isLoadingDetail;

  BusinessDetailState copyWith({
    BusinessDetailModel? detail,
    List<OfferingModel>? offerings,
    List<ReviewModel>? reviews,
    bool? isLoadingDetail,
    bool? isLoadingOfferings,
    bool? isLoadingReviews,
    String? error,
  }) {
    return BusinessDetailState(
      detail: detail ?? this.detail,
      offerings: offerings ?? this.offerings,
      reviews: reviews ?? this.reviews,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isLoadingOfferings: isLoadingOfferings ?? this.isLoadingOfferings,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      error: error ?? this.error,
    );
  }
}

class BusinessDetailNotifier extends StateNotifier<BusinessDetailState> {
  final Ref _ref;

  BusinessDetailNotifier(this._ref) : super(const BusinessDetailState());

  /// Loads only the core business detail — called immediately on screen open.
  Future<void> loadBusiness(int businessId) async {
    state = state.copyWith(isLoadingDetail: true, error: null);
    try {
      final repo = _ref.read(businessRepositoryProvider);
      final detail = await repo.getBusinessDetail(businessId);
      state = state.copyWith(detail: detail, isLoadingDetail: false);
    } catch (e) {
      state = state.copyWith(isLoadingDetail: false, error: e.toString());
    }
  }

  /// Loads menu offerings — called lazily when the Menu tab is first opened.
  Future<void> loadOfferings(int businessId) async {
    if (state.isLoadingOfferings) return;
    state = state.copyWith(isLoadingOfferings: true);
    try {
      final repo = _ref.read(businessRepositoryProvider);
      final offerings = await repo.getBusinessOfferings(businessId);
      state = state.copyWith(offerings: offerings, isLoadingOfferings: false);
    } catch (e) {
      state = state.copyWith(isLoadingOfferings: false);
    }
  }

  /// Loads reviews — called lazily when the Ratings tab is first opened.
  Future<void> loadReviews(int businessId) async {
    if (state.isLoadingReviews) return;
    state = state.copyWith(isLoadingReviews: true);
    try {
      final repo = _ref.read(businessRepositoryProvider);
      final reviews = await repo.getBusinessReviews(businessId);
      state = state.copyWith(reviews: reviews, isLoadingReviews: false);
    } catch (e) {
      state = state.copyWith(isLoadingReviews: false);
    }
  }
}

final businessDetailProvider =
    StateNotifierProvider.family<BusinessDetailNotifier, BusinessDetailState, int>(
  (ref, businessId) {
    final notifier = BusinessDetailNotifier(ref);
    notifier.loadBusiness(businessId);
    return notifier;
  },
);
