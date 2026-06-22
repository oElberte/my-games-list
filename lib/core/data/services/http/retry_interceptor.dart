import 'package:dio/dio.dart';

/// Retries idempotent (GET) requests that fail with a transient error —
/// connect/send/receive timeouts, connection drops, or a 5xx — using
/// exponential backoff. Non-GET requests and client errors (4xx) are never
/// retried, so non-idempotent calls can't be double-submitted.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 3,
    Duration Function(int attempt)? backoff,
  }) : _backoff = backoff ?? _defaultBackoff;

  final Dio _dio;
  final int maxRetries;
  final Duration Function(int attempt) _backoff;

  static const Set<int> _retryableStatus = {502, 503, 504};
  static const String _attemptKey = 'retry_attempt';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final attempt = (request.extra[_attemptKey] as int?) ?? 0;

    if (attempt < maxRetries && _isRetryable(err)) {
      final nextAttempt = attempt + 1;
      await Future<void>.delayed(_backoff(nextAttempt));
      request.extra[_attemptKey] = nextAttempt;
      try {
        handler.resolve(await _dio.fetch<dynamic>(request));
        return;
      } on DioException catch (e) {
        handler.next(e);
        return;
      }
    }
    handler.next(err);
  }

  bool _isRetryable(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') return false;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        return _retryableStatus.contains(err.response?.statusCode);
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return false;
    }
  }

  static Duration _defaultBackoff(int attempt) =>
      Duration(milliseconds: 300 * (1 << (attempt - 1)));
}
