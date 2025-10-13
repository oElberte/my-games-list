import 'package:my_games_list/data/models/requests/sign_in_request.dart';
import 'package:my_games_list/data/models/requests/sign_up_request.dart';
import 'package:my_games_list/data/models/responses/auth_response.dart';
import 'package:my_games_list/domain/repositories/i_auth_repository.dart';
import 'package:my_games_list/services/http/i_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of [IAuthRepository] that handles authentication operations
/// using the HTTP client and local storage.
class AuthRepository implements IAuthRepository {
  AuthRepository({
    required IHttpClient httpClient,
    required SharedPreferences prefs,
  }) : _httpClient = httpClient,
       _prefs = prefs;
  final IHttpClient _httpClient;
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';

  @override
  Future<AuthResponse> signIn(SignInRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/auth/signin',
      data: request.toJson(),
    );

    if (response.isError) {
      throw Exception(response.error?.userMessage ?? 'Sign in failed');
    }

    final authResponse = AuthResponse.fromJson(response.dataOrThrow);

    // Save token to local storage
    await saveToken(authResponse.token);

    // Set token in HTTP client for subsequent requests
    _httpClient.setAuthToken(authResponse.token);

    return authResponse;
  }

  @override
  Future<AuthResponse> signUp(SignUpRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/auth/signup',
      data: request.toJson(),
    );

    if (response.isError) {
      throw Exception(response.error?.userMessage ?? 'Sign up failed');
    }

    final authResponse = AuthResponse.fromJson(response.dataOrThrow);

    // Save token to local storage
    await saveToken(authResponse.token);

    // Set token in HTTP client for subsequent requests
    _httpClient.setAuthToken(authResponse.token);

    return authResponse;
  }

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    _httpClient.clearAuthToken();
  }
}
