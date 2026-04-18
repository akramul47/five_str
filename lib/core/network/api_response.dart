/// Generic wrapper for API responses.
/// All Laravel API responses follow: { success, message?, data }
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  /// Returns the first error message from the errors map, or the message.
  String get errorMessage {
    if (errors != null && errors!.isNotEmpty) {
      final firstErrors = errors!.values.first;
      if (firstErrors is List && firstErrors.isNotEmpty) {
        return firstErrors.first.toString();
      }
    }
    return message ?? 'An unexpected error occurred';
  }

  bool get isError => !success;
}
