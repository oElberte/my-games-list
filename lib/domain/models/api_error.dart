import 'package:equatable/equatable.dart';

/// Standardized API error model.
/// This model represents the error response format from the backend API.
///
/// Example JSON:
/// ```json
/// {
///   "name": "Validation Error: password",
///   "message": "Password is too short",
///   "action": "Password must be at least 6 characters long",
///   "status_code": 400,
///   "error_code": "error.validation.password.too_short"
/// }
/// ```
class ApiError extends Equatable {
  const ApiError({
    required this.name,
    required this.message,
    required this.action,
    required this.statusCode,
    required this.errorCode,
  });

  /// Creates an ApiError from JSON response.
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      name: json['name'] as String? ?? 'Unknown Error',
      message: json['message'] as String? ?? 'An error occurred',
      action: json['action'] as String? ?? 'Please try again',
      statusCode: json['status_code'] as int? ?? 500,
      errorCode: json['error_code'] as String? ?? 'error.unknown',
    );
  }

  /// The name/title of the error (e.g., "Validation Error: password")
  final String name;

  /// The error message describing what went wrong
  final String message;

  /// The suggested action to resolve the error
  final String action;

  /// HTTP status code
  final int statusCode;

  /// Machine-readable error code for i18n (e.g., "error.validation.password.too_short")
  final String errorCode;

  /// Returns a user-friendly formatted error string.
  /// Combines message and action for display.
  String get userMessage => '$message. $action';

  /// Returns just the message without the action.
  String get shortMessage => message;

  /// Converts the error to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
      'action': action,
      'status_code': statusCode,
      'error_code': errorCode,
    };
  }

  @override
  List<Object?> get props => [name, message, action, statusCode, errorCode];

  @override
  String toString() => userMessage;
}
