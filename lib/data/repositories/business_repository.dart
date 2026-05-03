import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/business_model.dart';
import '../models/category_model.dart';
import '../models/offering_model.dart';
import '../models/offer_model.dart';
import '../models/review_model.dart';

/// Paginated result wrapper.
class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
  });

  factory PaginatedResult.empty() {
    return const PaginatedResult(
      items: [],
      currentPage: 1,
      lastPage: 1,
      total: 0,
      hasMore: false,
    );
  }
}

class BusinessRepository {
  final DioClient _client;

  const BusinessRepository(this._client);

  // ── Listings ──

  Future<PaginatedResult<BusinessModel>> getBusinesses({
    required double latitude,
    required double longitude,
    int radius = 10,
    int page = 1,
    int limit = 20,
    int? categoryId,
    String sort = 'distance',
    double? minRating,
    bool? isVerified,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.businesses,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
          'page': page,
          'limit': limit,
          if (categoryId != null) 'category_id': categoryId,
          if (sort.isNotEmpty) 'sort': sort,
          if (minRating != null) 'min_rating': minRating,
          if (isVerified != null) 'is_verified': isVerified,
        },
      );
      return _parsePaginated(response, BusinessModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load businesses');
    }
  }

  Future<PaginatedResult<BusinessModel>> getByCategory({
    required int categoryId,
    required double latitude,
    required double longitude,
    int radius = 100,
    int page = 1,
    int perPage = 20,
    String sort = 'distance',
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.categoryBusinesses(categoryId),
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
          'page': page,
          'per_page': perPage,   // API uses per_page not limit
          'sort': sort,
        },
      );
      return _parsePaginated(response, BusinessModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load category businesses');
    }
  }

  Future<PaginatedResult<BusinessModel>> getTopRated({
    required double latitude,
    required double longitude,
    int radius = 20,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.topRated,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
          'page': page,
          'limit': limit,
        },
      );
      return _parsePaginated(response, BusinessModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load top rated');
    }
  }

  Future<PaginatedResult<BusinessModel>> getOpenNow({
    required double latitude,
    required double longitude,
    int radius = 10,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.openNow,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
          'page': page,
          'limit': limit,
        },
      );
      return _parsePaginated(response, BusinessModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load open businesses');
    }
  }

  Future<PaginatedResult<BusinessModel>> getTrending({
    required double latitude,
    required double longitude,
    int radius = 20,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.trending,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
          'page': page,
          'limit': limit,
        },
      );
      return _parsePaginated(response, BusinessModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load trending');
    }
  }

  // ── Detail ──

  Future<BusinessDetailModel> getBusinessDetail(int id) async {
    try {
      final response = await _client.get(ApiConfig.businessDetail(id));
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ??
          body['business'] as Map<String, dynamic>? ??
          body;
      return BusinessDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load business detail');
    }
  }

  Future<List<ReviewModel>> getBusinessReviews(
    int businessId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.businessReviews(businessId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return _parseList(
        _extractData(response),
        ReviewModel.fromJson,
      );
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load reviews');
    }
  }

  Future<List<OfferingModel>> getBusinessOfferings(int businessId) async {
    try {
      final response = await _client.get(
        ApiConfig.businessOfferings(businessId),
      );
      return _parseList(_extractData(response), OfferingModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load offerings');
    }
  }

  Future<OfferingModel> getOfferingDetail(
    int businessId,
    int offeringId,
  ) async {
    try {
      final response = await _client.get(
        ApiConfig.offeringDetail(businessId, offeringId),
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return OfferingModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load offering detail');
    }
  }

  Future<List<OfferModel>> getBusinessOffers(int businessId) async {
    try {
      final response = await _client.get(
        ApiConfig.businessOffers(businessId),
      );
      return _parseList(_extractData(response), OfferModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load business offers');
    }
  }

  // ── Categories ──

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.get(ApiConfig.categories);
      return _parseList(_extractData(response), CategoryModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load categories');
    }
  }

  Future<CategoryModel> getCategoryDetail(int id) async {
    try {
      final response = await _client.get(ApiConfig.categoryDetail(id));
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return CategoryModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load category');
    }
  }

  // ── Favourites ──

  Future<List<BusinessModel>> getUserFavorites() async {
    try {
      final response = await _client.get(ApiConfig.userFavorites);
      return _parseList(_extractData(response), BusinessModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load favorites');
    }
  }

  Future<void> addFavorite({
    required String favoritableType,
    required int favoritableId,
  }) async {
    try {
      await _client.post(
        ApiConfig.userFavorites,
        data: {
          'favoritable_type': favoritableType,
          'favoritable_id': favoritableId,
        },
      );
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to add favorite');
    }
  }

  Future<void> removeFavorite(int id) async {
    try {
      await _client.delete(ApiConfig.removeFavorite(id));
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to remove favorite');
    }
  }

  // ── Helpers ──

  PaginatedResult<T> _parsePaginated<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final body = response.data as Map<String, dynamic>;

    // The data can be directly the paginated object or nested in 'data'
    final paginated = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;

    final rawList = paginated['data'] as List<dynamic>? ??
        paginated['businesses'] as List<dynamic>? ??
        [];

    final paginationMeta = paginated['pagination'] as Map<String, dynamic>? ??
                           paginated['meta'] as Map<String, dynamic>? ??
                           paginated;

    final currentPage = paginationMeta['current_page'] as int? ?? 1;
    final lastPage   = paginationMeta['last_page']    as int? ?? 1;
    final total      = paginationMeta['total']         as int? ?? rawList.length;
    final perPage    = paginationMeta['per_page']      as int? ?? 20;

    // API provides has_more directly; fall back to page comparison
    final apiHasMore = paginationMeta['has_more'] as bool?;
    final hasMore = apiHasMore ?? 
        ((paginationMeta['next_page_url'] as String?) != null) ||
        currentPage < lastPage;

    debugPrint('══════════════════════════════════════════════════════');
    debugPrint('PAGINATION RESPONSE (raw top-level keys): ${body.keys.toList()}');
    debugPrint('paginated keys: ${paginated.keys.toList()}');
    debugPrint('page: $currentPage/$lastPage | per_page: $perPage | '
        'total: $total | items: ${rawList.length} | hasMore: $hasMore');
    debugPrint('has_more field: $apiHasMore | '
        'next_page_url: ${paginationMeta['next_page_url']}');
    debugPrint('══════════════════════════════════════════════════════');

    return PaginatedResult<T>(
      items: rawList
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(),
      currentPage: currentPage,
      lastPage:    lastPage,
      total:       total,
      hasMore:     hasMore,
    );
  }

  dynamic _extractData(Response response) {
    final body = response.data as Map<String, dynamic>;
    return body['data'] ?? body;
  }

  List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
    }
    if (raw is Map<String, dynamic>) {
      // Handle paginated or wrapped lists
      final list = raw['data'] ?? raw['businesses'] ?? raw['offerings'] ?? raw['reviews'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().map(fromJson).toList();
      }
    }
    return [];
  }

  ApiException _mapError(DioException e, String fallback) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException(message: e.message ?? fallback);
  }
}
