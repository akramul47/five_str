import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/business_model.dart';
import '../models/offering_model.dart';
import '../models/attraction_model.dart';

class SearchSuggestion {
  final String suggestion;
  final String type;
  final int? id;

  const SearchSuggestion({
    required this.suggestion,
    required this.type,
    this.id,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      suggestion: json['suggestion'] as String? ?? json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'business',
      id: json['id'] as int?,
    );
  }
}

class SearchResults {
  final List<BusinessModel> businesses;
  final List<OfferingModel> offerings;
  final List<AttractionModel> attractions;
  final int totalBusinesses;
  final int totalOfferings;
  final int totalAttractions;
  final int businessPage;
  final int offeringPage;
  final int attractionPage;
  final bool hasMoreBusinesses;
  final bool hasMoreOfferings;
  final bool hasMoreAttractions;

  const SearchResults({
    this.businesses = const [],
    this.offerings = const [],
    this.attractions = const [],
    this.totalBusinesses = 0,
    this.totalOfferings = 0,
    this.totalAttractions = 0,
    this.businessPage = 1,
    this.offeringPage = 1,
    this.attractionPage = 1,
    this.hasMoreBusinesses = false,
    this.hasMoreOfferings = false,
    this.hasMoreAttractions = false,
  });

  int get totalResults =>
      totalBusinesses + totalOfferings + totalAttractions;
}

class SearchRepository {
  final DioClient _client;

  const SearchRepository(this._client);

  /// Universal search across businesses, offerings, and attractions.
  Future<SearchResults> search({
    required String query,
    double? latitude,
    double? longitude,
    int radius = 20,
    String type = 'all',
    int? categoryId,
    double? minRating,
    bool? isVerified,
    String sort = 'relevance',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.search,
        queryParameters: {
          'q': query,
          'type': type,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          'radius': radius,
          if (categoryId != null) 'category_id': categoryId,
          if (minRating != null) 'min_rating': minRating,
          if (isVerified != null) 'is_verified': isVerified,
          'sort': sort,
          'page': page,
          'limit': limit,
        },
      );

      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      final results = data['results'] as Map<String, dynamic>? ?? data;

      return SearchResults(
        businesses: _parsePaginatedItems(
          results['businesses'],
          BusinessModel.fromJson,
        ),
        offerings: _parsePaginatedItems(
          results['offerings'],
          OfferingModel.fromJson,
        ),
        attractions: _parsePaginatedItems(
          results['attractions'],
          AttractionModel.fromJson,
        ),
        totalBusinesses: _extractTotal(results['businesses']),
        totalOfferings: _extractTotal(results['offerings']),
        totalAttractions: _extractTotal(results['attractions']),
        hasMoreBusinesses: _extractHasMore(results['businesses']),
        hasMoreOfferings: _extractHasMore(results['offerings']),
        hasMoreAttractions: _extractHasMore(results['attractions']),
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Search failed');
    }
  }

  /// Autocomplete suggestions (min 2 chars).
  Future<List<SearchSuggestion>> getSuggestions(
    String query, {
    int limit = 10,
  }) async {
    if (query.length < 2) return [];
    try {
      final response = await _client.get(
        ApiConfig.searchSuggestions,
        queryParameters: {'q': query, 'limit': limit},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] ?? body['suggestions'] ?? body;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(SearchSuggestion.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Failed to get suggestions');
    }
  }

  /// Popular search terms.
  Future<List<String>> getPopularSearches() async {
    try {
      final response = await _client.get(ApiConfig.searchPopular);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] ?? body['popular'] ?? body;
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Failed to get popular searches');
    }
  }

  // ── Helpers ──

  List<T> _parsePaginatedItems<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null) return [];
    List<dynamic>? list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map<String, dynamic>) {
      list = raw['data'] as List<dynamic>?;
    }
    return list?.whereType<Map<String, dynamic>>().map(fromJson).toList() ?? [];
  }

  int _extractTotal(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['total'] as int? ?? 0;
    }
    if (raw is List) return raw.length;
    return 0;
  }

  bool _extractHasMore(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['next_page_url'] != null;
    }
    return false;
  }
}
