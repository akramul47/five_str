import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/review_model.dart';
import 'business_repository.dart'; // For PaginatedResult

class ReviewRepository {
  final DioClient _client;

  const ReviewRepository(this._client);

  /// Submit a new review for a business or offering.
  Future<ReviewModel> submitReview({
    required String reviewableType,
    required int reviewableId,
    required int overallRating,
    int? serviceRating,
    int? qualityRating,
    int? valueRating,
    String? title,
    required String reviewText,
    List<String>? pros,
    List<String>? cons,
    String? visitDate,
    double? amountSpent,
    int? partySize,
    bool isRecommended = false,
    List<File>? images,
  }) async {
    try {
      final formData = FormData.fromMap({
        'reviewable_type': reviewableType,
        'reviewable_id': reviewableId,
        'overall_rating': overallRating,
        if (serviceRating != null) 'service_rating': serviceRating,
        if (qualityRating != null) 'quality_rating': qualityRating,
        if (valueRating != null) 'value_rating': valueRating,
        if (title != null && title.isNotEmpty) 'title': title,
        'review_text': reviewText,
        if (pros != null && pros.isNotEmpty) 'pros': pros,
        if (cons != null && cons.isNotEmpty) 'cons': cons,
        if (visitDate != null) 'visit_date': visitDate,
        if (amountSpent != null) 'amount_spent': amountSpent,
        if (partySize != null) 'party_size': partySize,
        'is_recommended': isRecommended ? 1 : 0,
      });

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final file = images[i];
          final fileName = file.path.split('/').last;
          formData.files.add(MapEntry(
            'images[$i]',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ));
        }
      }

      final response = await _client.post(
        ApiConfig.reviews,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return ReviewModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to submit review');
    }
  }

  /// Get details of a specific review.
  Future<ReviewModel> getReviewDetail(int reviewId) async {
    try {
      final response = await _client.get(ApiConfig.reviewDetail(reviewId));
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return ReviewModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load review');
    }
  }

  /// Update an existing review.
  Future<ReviewModel> updateReview({
    required int reviewId,
    int? overallRating,
    int? serviceRating,
    int? qualityRating,
    int? valueRating,
    String? title,
    String? reviewText,
    List<String>? pros,
    List<String>? cons,
    String? visitDate,
    double? amountSpent,
    int? partySize,
    bool? isRecommended,
  }) async {
    try {
      final response = await _client.put(
        ApiConfig.reviewDetail(reviewId),
        data: {
          if (overallRating != null) 'overall_rating': overallRating,
          if (serviceRating != null) 'service_rating': serviceRating,
          if (qualityRating != null) 'quality_rating': qualityRating,
          if (valueRating != null) 'value_rating': valueRating,
          if (title != null) 'title': title,
          if (reviewText != null) 'review_text': reviewText,
          if (pros != null) 'pros': pros,
          if (cons != null) 'cons': cons,
          if (visitDate != null) 'visit_date': visitDate,
          if (amountSpent != null) 'amount_spent': amountSpent,
          if (partySize != null) 'party_size': partySize,
          if (isRecommended != null) 'is_recommended': isRecommended ? 1 : 0,
        },
      );

      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return ReviewModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to update review');
    }
  }

  /// Delete a review.
  Future<void> deleteReview(int reviewId) async {
    try {
      await _client.delete(ApiConfig.reviewDetail(reviewId));
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to delete review');
    }
  }

  /// Vote on a review (helpful or not helpful).
  Future<void> voteReview({
    required int reviewId,
    required bool isHelpful,
  }) async {
    try {
      await _client.post(
        ApiConfig.reviewVote(reviewId),
        data: {'is_helpful': isHelpful},
      );
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to vote on review');
    }
  }
  
  /// Remove a vote on a review.
  Future<void> removeVote(int reviewId) async {
    try {
      await _client.delete(ApiConfig.reviewVoteRemove(reviewId));
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to remove vote');
    }
  }

  /// Get reviews by the current authenticated user.
  Future<PaginatedResult<ReviewModel>> getUserReviews({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.userReviews,
        queryParameters: {'page': page, 'limit': limit},
      );
      
      final body = response.data as Map<String, dynamic>;
      final paginated = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      final rawList = paginated['data'] as List<dynamic>? ?? paginated['reviews'] as List<dynamic>? ?? [];

      return PaginatedResult<ReviewModel>(
        items: rawList
            .whereType<Map<String, dynamic>>()
            .map(ReviewModel.fromJson)
            .toList(),
        currentPage: paginated['current_page'] as int? ?? 1,
        lastPage: paginated['last_page'] as int? ?? 1,
        total: paginated['total'] as int? ?? rawList.length,
        hasMore: (paginated['next_page_url'] as String?) != null,
      );
    } on DioException catch (e) {
      throw _mapError(e, 'Failed to load user reviews');
    }
  }

  // ── Helpers ──

  ApiException _mapError(DioException e, String fallback) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException(message: e.message ?? fallback);
  }
}
