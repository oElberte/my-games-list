import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_games_list/core/data/services/http/i_http_client.dart';
import 'package:my_games_list/features/auth/auth_response.dart';
import 'package:my_games_list/features/auth/domain/social_auth_request.dart';
import 'package:my_games_list/features/auth/sign_in/sign_in_request.dart';
import 'package:my_games_list/features/auth/sign_up/sign_up_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of AuthRepository that handles authentication operations
/// using the HTTP client and local storage.
class AuthRepository {
  AuthRepository({
    required IHttpClient httpClient,
    required SharedPreferences prefs,
  }) : _httpClient = httpClient,
       _prefs = prefs;
  final IHttpClient _httpClient;
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';

  Future<AuthResponse> signIn(SignInRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/auth/signin',
      data: request.toJson(),
    );

    if (response.isError) {
      throw Exception(response.error?.userMessage ?? 'Sign in failed');
    }

    return _persistAuthResponse(AuthResponse.fromJson(response.dataOrThrow));
  }

  Future<AuthResponse> signUp(SignUpRequest request) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/auth/signup',
      data: request.toJson(),
    );

    if (response.isError) {
      throw Exception(response.error?.userMessage ?? 'Sign up failed');
    }

    return _persistAuthResponse(AuthResponse.fromJson(response.dataOrThrow));
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithProvider(
        GoogleAuthProvider(),
      );
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw Exception('Failed to get Firebase ID token');

      return await _exchangeFirebaseToken('google', idToken);
    } catch (e) {
      throw Exception('Google sign-in failed. Please try again.');
    }
  }

  /// Exchanges a Firebase ID token for an app JWT by calling POST /auth/social.
  Future<AuthResponse> _exchangeFirebaseToken(
    String provider,
    String idToken,
  ) async {
    final request = SocialAuthRequest(
      provider: provider,
      firebaseIdToken: idToken,
    );

    final response = await _httpClient.post<Map<String, dynamic>>(
      '/auth/social',
      data: request.toJson(),
    );

    if (response.isError) {
      throw Exception(response.error?.userMessage ?? 'Social sign-in failed');
    }

    return _persistAuthResponse(AuthResponse.fromJson(response.dataOrThrow));
  }

  /// Persists the auth token to local storage and the HTTP client.
  Future<AuthResponse> _persistAuthResponse(AuthResponse authResponse) async {
    await saveToken(authResponse.token);
    _httpClient.setAuthToken(authResponse.token);
    return authResponse;
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    _httpClient.clearAuthToken();
  }
}
