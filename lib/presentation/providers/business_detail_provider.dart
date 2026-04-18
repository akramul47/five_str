import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/business_model.dart';
import '../../../data/models/offering_model.dart';
import '../../../data/models/review_model.dart';
import 'repository_providers.dart';

class BusinessDetailState {
  final BusinessDetailModel? detail;
  final List<OfferingModel> offerings;
  final List<ReviewModel> reviews;
  final bool isLoading;
  final String? error;

  const BusinessDetailState({
    this.detail,
    this.offerings = const [],
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  BusinessDetailState copyWith({
    BusinessDetailModel? detail,
    List<OfferingModel>? offerings,
    List<ReviewModel>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return BusinessDetailState(
      detail: detail ?? this.detail,
      offerings: offerings ?? this.offerings,
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BusinessDetailNotifier extends StateNotifier<BusinessDetailState> {
  final Ref _ref;

  BusinessDetailNotifier(this._ref) : super(const BusinessDetailState());

  Future<void> loadBusiness(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = _ref.read(businessRepositoryProvider);

      // We run all remote fetches concurrently to speed up the UX
      final results = await Future.wait([
        repo.getBusinessDetail(businessId),
        repo.getBusinessOfferings(businessId),
        repo.getBusinessReviews(businessId),
      ]);

      state = state.copyWith(
        detail: results[0] as BusinessDetailModel,
        offerings: results[1] as List<OfferingModel>,
        reviews: results[2] as List<ReviewModel>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final businessDetailProvider =
    StateNotifierProvider.family<BusinessDetailNotifier, BusinessDetailState, int>(
  (ref, businessId) {
    final notifier = BusinessDetailNotifier(ref);
    // Auto-fetch when the provider is initialized
    notifier.loadBusiness(businessId);
    return notifier;
  },
);
