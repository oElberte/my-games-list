import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_games_list/core/data/services/http/i_http_client.dart';
import 'package:my_games_list/features/auth/auth_response.dart';
import 'package:my_games_list/features/auth/domain/social_auth_request.dart';
import 'package:my_games_list/features/auth/sign_in/sign_in_request.dart';
import 'package:my_games_list/features/auth/sign_up/sign_up_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

    final authResponse = AuthResponse.fromJson(response.dataOrThrow);

    // Save token to local storage
    await saveToken(authResponse.token);

    // Set token in HTTP client for subsequent requests
    _httpClient.setAuthToken(authResponse.token);

    return authResponse;
  }

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

  Future<AuthResponse> signInWithGoogle() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithProvider(GoogleAuthProvider());
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw Exception('Failed to get Firebase ID token');

      return await _exchangeFirebaseToken('google', idToken);
    } catch (e) {
      throw Exception('Google sign-in failed. Please try again.');
    }
  }

  Future<AuthResponse> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw Exception('Failed to get Firebase ID token');

      return await _exchangeFirebaseToken('apple', idToken);
    } catch (e) {
      throw Exception('Apple sign-in failed. Please try again.');
    }
  }

  /// Exchanges a Firebase ID token for an app JWT by calling POST /auth/social.
  /// Mirrors the token saving pattern of [signIn] and [signUp] exactly.
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

    final authResponse = AuthResponse.fromJson(response.dataOrThrow);

    // Save token to local storage
    await saveToken(authResponse.token);

    // Set token in HTTP client for subsequent requests
    _httpClient.setAuthToken(authResponse.token);

    return authResponse;
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
