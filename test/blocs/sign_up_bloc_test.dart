import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/blocs/sign_up/sign_up_bloc.dart';
import 'package:my_games_list/blocs/sign_up/sign_up_event.dart';
import 'package:my_games_list/blocs/sign_up/sign_up_state.dart';
import 'package:my_games_list/data/models/requests/sign_up_request.dart';
import 'package:my_games_list/data/models/responses/auth_response.dart';
import 'package:my_games_list/domain/entities/user.dart';
import 'package:my_games_list/domain/repositories/i_auth_repository.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignUpBloc bloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    bloc = SignUpBloc(mockAuthRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const SignUpRequest(
        email: 'test@example.com',
        password: 'password123',
        username: 'testuser',
      ),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('SignUpBloc Tests', () {
    const testEmail = 'newuser@example.com';
    const testPassword = 'password123';
    const testUsername = 'newuser';

    const mockAuthResponse = AuthResponse(
      token: 'new-token-456',
      user: User(id: 'user-2', email: testEmail, username: testUsername),
    );

    test('initial state is SignUpInitial', () {
      expect(bloc.state, equals(const SignUpInitial()));
    });

    blocTest<SignUpBloc, SignUpState>(
      'emits [SignUpLoading, SignUpSuccess] when signUp succeeds',
      build: () {
        when(
          () => mockAuthRepository.signUp(any()),
        ).thenAnswer((_) async => mockAuthResponse);
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SignUpSubmitted(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        ),
      ),
      expect: () => [
        const SignUpLoading(),
        const SignUpSuccess(mockAuthResponse),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signUp(any())).called(1);
      },
    );

    blocTest<SignUpBloc, SignUpState>(
      'emits [SignUpLoading, SignUpError] when signUp fails',
      build: () {
        when(
          () => mockAuthRepository.signUp(any()),
        ).thenThrow(Exception('Email already exists'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SignUpSubmitted(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        ),
      ),
      expect: () => [
        const SignUpLoading(),
        const SignUpError('Email already exists'),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signUp(any())).called(1);
      },
    );

    blocTest<SignUpBloc, SignUpState>(
      'emits [SignUpLoading, SignUpError] when validation fails',
      build: () {
        when(
          () => mockAuthRepository.signUp(any()),
        ).thenThrow(Exception('Bad request. Please check your input.'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SignUpSubmitted(
          email: testEmail,
          password: testPassword,
          username: testUsername,
        ),
      ),
      expect: () => [
        const SignUpLoading(),
        const SignUpError('Bad request. Please check your input.'),
      ],
    );
  });
}
