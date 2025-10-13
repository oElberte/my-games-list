import 'package:my_games_list/data/models/requests/sign_in_request.dart';
import 'package:my_games_list/data/models/requests/sign_up_request.dart';
import 'package:my_games_list/data/models/responses/auth_response.dart';

/// Interface for authentication repository operations.
/// This abstraction allows for easy swapping of authentication implementations.
abstract class IAuthRepository {
  /// Signs in a user with the provided [request].
  /// Returns an [AuthResponse] containing the token and user data on success.
  /// Throws an exception on failure.
  Future<AuthResponse> signIn(SignInRequest request);

  /// Signs up a new user with the provided [request].
  /// Returns an [AuthResponse] containing the token and user data on success.
  /// Throws an exception on failure.
  Future<AuthResponse> signUp(SignUpRequest request);

  /// Saves the authentication token to local storage.
  Future<void> saveToken(String token);

  /// Retrieves the authentication token from local storage.
  /// Returns null if no token is found.
  Future<String?> getToken();

  /// Clears the authentication token from local storage.
  Future<void> clearToken();
}
