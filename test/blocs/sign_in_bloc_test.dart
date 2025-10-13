import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/blocs/sign_in/sign_in_bloc.dart';
import 'package:my_games_list/blocs/sign_in/sign_in_event.dart';
import 'package:my_games_list/blocs/sign_in/sign_in_state.dart';
import 'package:my_games_list/data/models/requests/sign_in_request.dart';
import 'package:my_games_list/data/models/responses/auth_response.dart';
import 'package:my_games_list/domain/entities/user.dart';
import 'package:my_games_list/domain/repositories/i_auth_repository.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignInBloc bloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    bloc = SignInBloc(mockAuthRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const SignInRequest(email: 'test@example.com', password: 'password123'),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('SignInBloc Tests', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    const mockAuthResponse = AuthResponse(
      token: 'test-token-123',
      user: User(id: 'user-1', email: testEmail, username: 'testuser'),
    );

    test('initial state is SignInInitial', () {
      expect(bloc.state, equals(const SignInInitial()));
    });

    blocTest<SignInBloc, SignInState>(
      'emits [SignInLoading, SignInSuccess] when signIn succeeds',
      build: () {
        when(
          () => mockAuthRepository.signIn(any()),
        ).thenAnswer((_) async => mockAuthResponse);
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SignInSubmitted(email: testEmail, password: testPassword),
      ),
      expect: () => [
        const SignInLoading(),
        const SignInSuccess(mockAuthResponse),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signIn(any())).called(1);
      },
    );

    blocTest<SignInBloc, SignInState>(
      'emits [SignInLoading, SignInError] when signIn fails',
      build: () {
        when(
          () => mockAuthRepository.signIn(any()),
        ).thenThrow(Exception('Invalid credentials'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SignInSubmitted(email: testEmail, password: testPassword),
      ),
      expect: () => [
        const SignInLoading(),
        const SignInError('Invalid credentials'),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signIn(any())).called(1);
      },
    );

    blocTest<SignInBloc, SignInState>(
      'emits [SignInLoading, SignInError] when network error occurs',
      build: () {
        when(() => mockAuthRepository.signIn(any())).thenThrow(
          Exception('No internet connection. Please check your network.'),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SignInSubmitted(email: testEmail, password: testPassword),
      ),
      expect: () => [
        const SignInLoading(),
        const SignInError('No internet connection. Please check your network.'),
      ],
    );
  });
}
