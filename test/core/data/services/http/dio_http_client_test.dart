import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/core/data/services/http/dio_http_client.dart';

/// Adapter that returns a fixed status code for every request.
class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.statusCode);

  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('DioHttpClient auto-logout on 401', () {
    DioHttpClient buildClient(int status) {
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local/'))
        ..httpClientAdapter = _StatusAdapter(status);
      return DioHttpClient(dio: dio);
    }

    test('an authenticated 401 triggers onUnauthorized exactly once', () async {
      var calls = 0;
      final client = buildClient(401)
        ..setOnUnauthorized(() => calls++)
        ..setAuthToken('token');

      await client.get<dynamic>('/games/recommendations');
      await client.get<dynamic>('/games/recommendations'); // debounced

      expect(calls, 1);
    });

    test('a 401 without an auth header does not trigger logout', () async {
      var calls = 0;
      final client = buildClient(401)..setOnUnauthorized(() => calls++);
      // No setAuthToken → e.g. the startup FCM call before login.
      await client.get<dynamic>('/users/me/fcm-token');

      expect(calls, 0);
    });

    test('a 401 on an auth endpoint does not trigger logout', () async {
      var calls = 0;
      final client = buildClient(401)
        ..setOnUnauthorized(() => calls++)
        ..setAuthToken('token');
      await client.post<dynamic>('/auth/signin', data: <String, dynamic>{});

      expect(calls, 0);
    });

    test('a non-401 error does not trigger logout', () async {
      var calls = 0;
      final client = buildClient(500)
        ..setOnUnauthorized(() => calls++)
        ..setAuthToken('token');
      await client.get<dynamic>('/games/recommendations');

      expect(calls, 0);
    });
  });
}
