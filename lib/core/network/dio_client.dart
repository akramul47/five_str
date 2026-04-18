import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../errors/exceptions.dart';
import '../../data/services/auth_service.dart';

/// Centralized Dio HTTP client with auth interceptor.
class DioClient {
  late final Dio _dio;
  final AuthService _authService;

  DioClient({required AuthService authService}) : _authService = authService {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor(),
      _errorInterceptor(),
      if (kDebugMode) _loggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  /// Attaches Bearer token to every request if available.
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }

  /// Maps Dio errors to app-specific exceptions.
  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: const NetworkException(
                message: 'Connection timed out. Please try again.',
              ),
            ),
          );
          return;
        }

        if (error.type == DioExceptionType.connectionError) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: const NetworkException(),
            ),
          );
          return;
        }

        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 401:
            await _authService.clearToken();
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const UnauthorizedException(),
              ),
            );
            return;
          case 404:
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: NotFoundException(
                  message: data?['message'] ?? 'Resource not found',
                ),
              ),
            );
            return;
          case 422:
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: ValidationException(
                  message: data?['message'] ?? 'Validation failed',
                  errors: data?['errors'] as Map<String, dynamic>?,
                ),
              ),
            );
            return;
          case 429:
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const ApiException(
                  message: 'Too many requests. Please wait a moment.',
                  statusCode: 429,
                ),
              ),
            );
            return;
          case 500:
          case 502:
          case 503:
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const ServerException(),
              ),
            );
            return;
        }

        handler.next(error);
      },
    );
  }

  /// Debug-only request/response logger.
  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('→ ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint(
          '✕ ${error.response?.statusCode} ${error.requestOptions.uri}: '
          '${error.message}',
        );
        handler.next(error);
      },
    );
  }

  // ── Convenience methods ──

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return _dio.patch(path, data: data, options: options);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return _dio.delete(path, data: data, options: options);
  }
}
