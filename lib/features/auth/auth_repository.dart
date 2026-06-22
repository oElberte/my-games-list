import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_games_list/core/data/services/http/i_http_client.dart';
import 'package:my_games_list/features/auth/auth_response.dart';
import 'package:my_games_list/features/auth/domain/social_auth_request.dart';
import 'package:my_games_list/features/auth/sign_in/sign_in_request.dart';
import 'package:my_games_list/features/auth/sign_up/sign_up_request.dart';
import 'package:my_games_list/core/data/services/storage/token_storage.dart';

/// Implementation of AuthRepository that handles authentication operations
/// using the HTTP client and local storage.
class AuthRepository {
  AuthRepository({
    required IHttpClient httpClient,
    required TokenStorage tokenStorage,
  }) : _httpClient = httpClient,
       _tokenStorage = tokenStorage;
  final IHttpClient _httpClient;
  final TokenStorage _tokenStorage;

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

  /// Authenticates with Google. [consentVersion] is the Privacy Policy / Terms
  /// version the user accepted on the auth screen; the API requires it on
  /// `/auth/social` for account creation.
  Future<AuthResponse> signInWithGoogle({
    required String consentVersion,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithProvider(
        GoogleAuthProvider(),
      );
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw Exception('Failed to get Firebase ID token');

      return await _exchangeFirebaseToken('google', idToken, consentVersion);
    } catch (e) {
      throw Exception('Google sign-in failed. Please try again.');
    }
  }

  /// Exchanges a Firebase ID token for an app JWT by calling POST /auth/social.
  Future<AuthResponse> _exchangeFirebaseToken(
    String provider,
    String idToken,
    String consentVersion,
  ) async {
    final request = SocialAuthRequest(
      provider: provider,
      firebaseIdToken: idToken,
      consentVersion: consentVersion,
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
    await _tokenStorage.write(token);
  }

  Future<String?> getToken() => _tokenStorage.read();

  Future<void> clearToken() async {
    await _tokenStorage.delete();
    _httpClient.clearAuthToken();
  }

  /// Permanently deletes the authenticated user's account via DELETE /users/me.
  /// On success the backend returns 204 with no body; the caller is responsible
  /// for tearing down the local session afterwards.
  Future<void> deleteAccount() async {
    final response = await _httpClient.delete<void>('/users/me');

    if (response.isError) {
      throw Exception(response.error?.userMessage ?? 'Account deletion failed');
    }
  }

  /// Fetches the authenticated user's data export via GET /users/me/export and
  /// returns it as pretty-printed JSON ready to be saved or shared.
  Future<String> exportData() async {
    final response = await _httpClient.get<Map<String, dynamic>>(
      '/users/me/export',
    );

    if (response.isError) {
      throw Exception(response.error?.userMessage ?? 'Data export failed');
    }

    return const JsonEncoder.withIndent('  ').convert(response.dataOrThrow);
  }
}
