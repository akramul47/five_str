/// Custom exceptions for the app.

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'Unauthorized'})
      : super(statusCode: 401);
}

class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Resource not found'})
      : super(statusCode: 404);
}

class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Validation failed',
    super.errors,
  }) : super(statusCode: 422);
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
  });
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error. Please try again later.',
  }) : super(statusCode: 500);
}
