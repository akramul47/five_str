import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/attraction_model.dart';
import '../models/review_model.dart';
import 'business_repository.dart'; // For PaginatedResult

class AttractionRepository {
  final DioClient _client;

  const AttractionRepository(this._client);

  // ── Listings ──

  Future<PaginatedResult<AttractionModel>> getAttractions({
    double? latitude,
    double? longitude,
    int radius = 50,
    int page = 1,
    int limit = 20,
    String? category,
    String sort = 'distance',
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.attractions,
        queryParameters: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'radius': radius,
          'page': page,
          'limit': limit,
          if (category != null) 'category': category,
          'sort': sort,
        },
      );
      return _parsePaginated(response, AttractionModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load attractions');
    }
  }

  Future<List<AttractionModel>> getFeaturedAttractions({
    double? latitude,
    double? longitude,
    int limit = 10,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.attractionsFeatured,
        queryParameters: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'limit': limit,
        },
      );
      return _parseList(_extractData(response), AttractionModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load featured attractions');
    }
  }

  Future<List<AttractionModel>> getPopularAttractions({
    double? latitude,
    double? longitude,
    int limit = 10,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.attractionsPopular,
        queryParameters: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'limit': limit,
        },
      );
      return _parseList(_extractData(response), AttractionModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load popular attractions');
    }
  }

  // ── Detail ──

  Future<AttractionModel> getAttractionDetail(int id) async {
    try {
      final response = await _client.get(ApiConfig.attractionDetail(id));
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body['attraction'] as Map<String, dynamic>? ?? body;
      return AttractionModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load attraction detail');
    }
  }

  Future<List<String>> getAttractionGallery(int id) async {
    try {
      final response = await _client.get(ApiConfig.attractionGallery(id));
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] ?? body['gallery'] ?? body;
      if (data is List) {
        return data.map((e) => e['image_url'] as String? ?? e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load gallery');
    }
  }

  Future<PaginatedResult<ReviewModel>> getAttractionReviews(
    int attractionId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.attractionReviews(attractionId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return _parsePaginated(response, ReviewModel.fromJson);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load attraction reviews');
    }
  }

  // ── Interactions ──

  Future<void> toggleInteraction({
    required int attractionId,
    required String interactionType, // 'like', 'dislike', 'bookmark', 'wishlist'
  }) async {
    try {
      await _client.post(
        ApiConfig.attractionInteractionsToggle,
        data: {
          'attraction_id': attractionId,
          'interaction_type': interactionType,
        },
      );
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to toggle interaction');
    }
  }

  Future<Map<String, bool>> getInteractionStatus(int attractionId) async {
    try {
      final response = await _client.get(
        ApiConfig.attractionInteractionStatus(attractionId),
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return {
        'is_liked': data['is_liked'] as bool? ?? false,
        'is_disliked': data['is_disliked'] as bool? ?? false,
        'is_bookmarked': data['is_bookmarked'] as bool? ?? false,
        'is_wishlisted': data['is_wishlisted'] as bool? ?? false,
      };
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to get interaction status');
    }
  }

  // ── Helpers ──

  PaginatedResult<T> _parsePaginated<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final body = response.data as Map<String, dynamic>;
    final paginated = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;

    final rawList = paginated['data'] as List<dynamic>? ??
        paginated['attractions'] as List<dynamic>? ??
        paginated['reviews'] as List<dynamic>? ??
        [];

    return PaginatedResult<T>(
      items: rawList
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(),
      currentPage: paginated['current_page'] as int? ?? 1,
      lastPage: paginated['last_page'] as int? ?? 1,
      total: paginated['total'] as int? ?? rawList.length,
      hasMore: (paginated['next_page_url'] as String?) != null,
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
      final list = raw['data'] ?? raw['attractions'];
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
