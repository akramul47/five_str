import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/banner_model.dart';
import '../models/business_model.dart';
import '../models/category_model.dart';
import '../models/offer_model.dart';
import '../models/attraction_model.dart';
import '../models/home_section_models.dart';

/// Response object for the /home endpoint.
class HomeResponse {
  final List<BannerModel> banners;
  final List<CategoryModel> topServices;
  final List<BusinessModel> popularNearby;
  final List<BusinessModel> trendingBusinesses;
  final List<BusinessModel> featuredBusinesses;
  final List<AttractionModel> featuredAttractions;
  final List<AttractionModel> popularAttractions;
  final List<OfferModel> specialOffers;
  final List<NationalBrandSection> nationalBrands;
  final List<DynamicSection> dynamicSections;

  const HomeResponse({
    this.banners = const [],
    this.topServices = const [],
    this.popularNearby = const [],
    this.trendingBusinesses = const [],
    this.featuredBusinesses = const [],
    this.featuredAttractions = const [],
    this.popularAttractions = const [],
    this.specialOffers = const [],
    this.nationalBrands = const [],
    this.dynamicSections = const [],
  });
}

class HomeRepository {
  final DioClient _client;

  const HomeRepository(this._client);

  /// Fetch all home screen data in one request.
  Future<HomeResponse> getHomeData({
    required double latitude,
    required double longitude,
    int radius = 10,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.home,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      debugPrint('HOME API RAW: ${response.data}');

      final data = _extractData(response);

      return HomeResponse(
        banners: _parseList(data['banners'], BannerModel.fromJson),
        topServices: _parseList(data['top_services'], CategoryModel.fromJson),
        popularNearby:
            _parseList(data['popular_nearby'], BusinessModel.fromJson),
        trendingBusinesses:
            _parseList(data['trending_businesses'], BusinessModel.fromJson),
        featuredBusinesses:
            _parseList(data['featured_businesses'], BusinessModel.fromJson),
        featuredAttractions:
            _parseList(data['featured_attractions'], AttractionModel.fromJson),
        popularAttractions:
            _parseList(data['popular_attractions'], AttractionModel.fromJson),
        specialOffers:
            _parseList(data['special_offers'], OfferModel.fromJson),
        nationalBrands: _parseList(
            data['top_national_brands'], NationalBrandSection.fromJson),
        dynamicSections:
            _parseList(data['dynamic_sections'], DynamicSection.fromJson),
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Failed to load home data');
    }
  }

  /// Fetch all top service categories (no location).
  Future<List<CategoryModel>> getTopServices() async {
    try {
      final response = await _client.get(ApiConfig.topServices);
      final data = _extractData(response);
      return _parseList(
        data is List ? data : data['categories'],
        CategoryModel.fromJson,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Failed to load categories');
    }
  }

  /// Fetch top service categories with location context + full debug logging.
  Future<List<CategoryModel>> getTopServicesWithLocation({
    required double latitude,
    required double longitude,
    int radius = 10,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.topServices,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      debugPrint('══════════════════════════════════════════════════════════');
      debugPrint('TOP SERVICES API → ${ApiConfig.topServices}');
      debugPrint('Params: lat=$latitude, lng=$longitude, radius=$radius');
      debugPrint('RAW RESPONSE: ${response.data}');

      final body = response.data as Map<String, dynamic>;
      // The API may wrap in data:{} or return categories directly
      final inner = body['data'];
      List<CategoryModel> categories;

      if (inner is List) {
        // data is a plain list
        debugPrint('Response shape: data is List (${inner.length} items)');
        categories = _parseList(inner, CategoryModel.fromJson);
      } else if (inner is Map<String, dynamic>) {
        // data is a map — try common keys
        final rawList = inner['categories'] ??
            inner['top_services'] ??
            inner['data'] ??
            inner;
        debugPrint('Response shape: data is Map, using key → rawList');
        categories = _parseList(
          rawList is List ? rawList : null,
          CategoryModel.fromJson,
        );
      } else {
        // No data wrapper — try top-level keys
        final rawList = body['categories'] ??
            body['top_services'] ??
            body['data'];
        debugPrint('Response shape: no data wrapper, top-level keys');
        categories = _parseList(
          rawList is List ? rawList : null,
          CategoryModel.fromJson,
        );
      }

      debugPrint('Parsed ${categories.length} categories:');
      for (final cat in categories) {
        debugPrint(
          '  [${cat.id}] ${cat.name} | businesses: ${cat.totalBusinesses} | '
          'featured: ${cat.isFeatured} | popular: ${cat.isPopular} | '
          'color: ${cat.colorCode}',
        );
      }
      debugPrint('══════════════════════════════════════════════════════════');

      return categories;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Failed to load categories');
    }
  }


  /// Fetch popular nearby businesses.
  Future<List<BusinessModel>> getPopularNearby({
    required double latitude,
    required double longitude,
    int radius = 10,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.popularNearby,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
          'limit': limit,
          'page': page,
        },
      );
      final data = _extractData(response);
      final list = data is List ? data : data['businesses'] ?? data['data'];
      return _parseList(list, BusinessModel.fromJson);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Failed to load nearby');
    }
  }

  /// Fetch featured businesses.
  Future<List<BusinessModel>> getFeaturedBusinesses({
    required double latitude,
    required double longitude,
    int limit = 10,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.featuredBusinesses,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'limit': limit,
        },
      );
      final data = _extractData(response);
      final list = data is List ? data : data['businesses'] ?? data['data'];
      return _parseList(list, BusinessModel.fromJson);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Failed to load featured');
    }
  }

  /// Fetch special offers.
  Future<List<OfferModel>> getSpecialOffers({int limit = 10}) async {
    try {
      final response = await _client.get(
        ApiConfig.specialOffers,
        queryParameters: {'limit': limit},
      );
      final data = _extractData(response);
      final list = data is List ? data : data['offers'] ?? data['data'];
      return _parseList(list, OfferModel.fromJson);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Failed to load offers');
    }
  }

  /// Fetch national brand sections.
  Future<List<NationalBrandSection>> getNationalBrands() async {
    try {
      final response = await _client.get(ApiConfig.nationalBrands);
      final data = _extractData(response);
      final list = data is List ? data : data['sections'] ?? data['data'];
      return _parseList(list, NationalBrandSection.fromJson);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: e.message ?? 'Failed to load brands');
    }
  }

  // ── Helpers ──

  Map<String, dynamic> _extractData(Response response) {
    final body = response.data as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>? ?? body;
  }

  List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
    }
    return [];
  }
}
