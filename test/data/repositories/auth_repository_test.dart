import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/data/models/requests/sign_in_request.dart';
import 'package:my_games_list/data/models/requests/sign_up_request.dart';
import 'package:my_games_list/data/models/responses/auth_response.dart';
import 'package:my_games_list/data/repositories/auth_repository.dart';
import 'package:my_games_list/domain/models/api_error.dart';
import 'package:my_games_list/domain/models/api_response.dart';
import 'package:my_games_list/services/http/i_http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClient extends Mock implements IHttpClient {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AuthRepository repository;
  late MockHttpClient mockHttpClient;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockPrefs = MockSharedPreferences();
    repository = AuthRepository(httpClient: mockHttpClient, prefs: mockPrefs);
  });

  group('AuthRepository SignIn Tests', () {
    const signInRequest = SignInRequest(
      email: 'test@example.com',
      password: 'password123',
    );

    final mockAuthData = {
      'token': 'test-token-123',
      'user': {
        'id': 'user-1',
        'email': 'test@example.com',
        'username': 'testuser',
      },
    };

    test('signIn succeeds with valid credentials', () async {
      // Arrange
      when(
        () => mockHttpClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => ApiResponse.success(mockAuthData));

      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      // Act
      final result = await repository.signIn(signInRequest);

      // Assert
      expect(result, isA<AuthResponse>());
      expect(result.token, 'test-token-123');
      expect(result.user.email, 'test@example.com');
      expect(result.user.username, 'testuser');

      verify(
        () => mockHttpClient.post<Map<String, dynamic>>(
          '/auth/signin',
          data: signInRequest.toJson(),
        ),
      ).called(1);
      verify(
        () => mockPrefs.setString('auth_token', 'test-token-123'),
      ).called(1);
      verify(() => mockHttpClient.setAuthToken('test-token-123')).called(1);
    });

    test('signIn throws exception on API error', () async {
      // Arrange
      when(
        () => mockHttpClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => ApiResponse.failure(
          const ApiError(
            name: 'Sign In',
            message: 'Invalid credentials',
            action: 'sign_in',
            statusCode: 401,
            errorCode: 'invalid_credentials',
          ),
        ),
      );

      // Act & Assert
      expect(() => repository.signIn(signInRequest), throwsA(isA<Exception>()));
    });
  });

  group('AuthRepository SignUp Tests', () {
    const signUpRequest = SignUpRequest(
      email: 'newuser@example.com',
      password: 'password123',
      username: 'newuser',
    );

    final mockAuthData = {
      'token': 'new-token-456',
      'user': {
        'id': 'user-2',
        'email': 'newuser@example.com',
        'username': 'newuser',
      },
    };

    test('signUp succeeds with valid data', () async {
      // Arrange
      when(
        () => mockHttpClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => ApiResponse.success(mockAuthData));

      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      // Act
      final result = await repository.signUp(signUpRequest);

      // Assert
      expect(result, isA<AuthResponse>());
      expect(result.token, 'new-token-456');
      expect(result.user.email, 'newuser@example.com');
      expect(result.user.username, 'newuser');

      verify(
        () => mockHttpClient.post<Map<String, dynamic>>(
          '/auth/signup',
          data: signUpRequest.toJson(),
        ),
      ).called(1);
      verify(
        () => mockPrefs.setString('auth_token', 'new-token-456'),
      ).called(1);
      verify(() => mockHttpClient.setAuthToken('new-token-456')).called(1);
    });

    test('signUp throws exception on API error', () async {
      // Arrange
      when(
        () => mockHttpClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => ApiResponse.failure(
          const ApiError(
            name: 'Sign Up',
            message: 'Email already exists',
            action: 'sign_up',
            statusCode: 400,
            errorCode: 'email_exists',
          ),
        ),
      );

      // Act & Assert
      expect(() => repository.signUp(signUpRequest), throwsA(isA<Exception>()));
    });
  });

  group('AuthRepository Token Management Tests', () {
    test('saveToken stores token in SharedPreferences', () async {
      // Arrange
      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      // Act
      await repository.saveToken('test-token');

      // Assert
      verify(() => mockPrefs.setString('auth_token', 'test-token')).called(1);
    });

    test('getToken retrieves token from SharedPreferences', () async {
      // Arrange
      when(() => mockPrefs.getString(any())).thenReturn('stored-token');

      // Act
      final result = await repository.getToken();

      // Assert
      expect(result, 'stored-token');
      verify(() => mockPrefs.getString('auth_token')).called(1);
    });

    test('getToken returns null when no token is stored', () async {
      // Arrange
      when(() => mockPrefs.getString(any())).thenReturn(null);

      // Act
      final result = await repository.getToken();

      // Assert
      expect(result, isNull);
      verify(() => mockPrefs.getString('auth_token')).called(1);
    });

    test('clearToken removes token and clears auth header', () async {
      // Arrange
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
      when(() => mockHttpClient.clearAuthToken()).thenReturn(null);

      // Act
      await repository.clearToken();

      // Assert
      verify(() => mockPrefs.remove('auth_token')).called(1);
      verify(() => mockHttpClient.clearAuthToken()).called(1);
    });
  });
}
