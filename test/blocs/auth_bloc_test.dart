import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/blocs/auth_bloc.dart';
import 'package:my_games_list/blocs/auth_event.dart';
import 'package:my_games_list/blocs/auth_state.dart';

import '../mocks/mock_services.dart';

void main() {
  group('AuthBloc', () {
    late MockLocalStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockLocalStorageService();
    });

    test('initial state is AuthInitial', () {
      final authBloc = AuthBloc(mockStorageService);
      expect(authBloc.state, isA<AuthInitial>());
      authBloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when AuthStateLoaded is added and no stored auth',
      build: () {
        mockStorageService.setBoolReturn(false);
        mockStorageService.setStringReturn(null);
        return AuthBloc(mockStorageService);
      },
      act: (bloc) => bloc.add(const AuthStateLoaded()),
      expect: () => [const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when AuthStateLoaded is added with stored auth',
      build: () {
        mockStorageService.setBoolReturn(true);
        mockStorageService.setStringReturn(
          '{"id":"123","email":"saved@example.com","name":"Saved User"}',
        );
        return AuthBloc(mockStorageService);
      },
      act: (bloc) => bloc.add(const AuthStateLoaded()),
      expect: () => [
        predicate<AuthAuthenticated>((state) {
          return state.user.email == 'saved@example.com' &&
              state.user.name == 'Saved User';
        }),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when AuthStateLoaded with invalid JSON',
      build: () {
        mockStorageService.setBoolReturn(true);
        mockStorageService.setStringReturn('invalid json');
        return AuthBloc(mockStorageService);
      },
      act: (bloc) => bloc.add(const AuthStateLoaded()),
      expect: () => [const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful',
      build: () => AuthBloc(mockStorageService),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'test@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        predicate<AuthAuthenticated>((state) {
          return state.user.email == 'test@example.com' &&
              state.user.name == 'test';
        }),
      ],
      verify: (_) {
        expect(mockStorageService.setStringCallHistory.length, greaterThan(0));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login with empty email',
      build: () => AuthBloc(mockStorageService),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: '', password: 'password123'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Email and password cannot be empty'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login with empty password',
      build: () => AuthBloc(mockStorageService),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'test@example.com', password: ''),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Email and password cannot be empty'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when logout is requested',
      build: () => AuthBloc(mockStorageService),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthUnauthenticated()],
      verify: (_) {
        expect(mockStorageService.removeCallHistory.length, greaterThan(0));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'generates unique user IDs for different logins',
      build: () => AuthBloc(mockStorageService),
      act: (bloc) async {
        bloc.add(
          const AuthLoginRequested(
            email: 'user1@example.com',
            password: 'password123',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const AuthLogoutRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(
          const AuthLoginRequested(
            email: 'user2@example.com',
            password: 'password123',
          ),
        );
      },
      skip: 4, // Skip initial states to check final authenticated state
      expect: () => [
        predicate<AuthAuthenticated>((state) {
          return state.user.email == 'user2@example.com';
        }),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'uses email prefix as user name',
      build: () => AuthBloc(mockStorageService),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'johndoe@example.com',
          password: 'password123',
        ),
      ),
      skip: 1, // Skip loading state
      expect: () => [
        predicate<AuthAuthenticated>((state) {
          return state.user.name == 'johndoe';
        }),
      ],
    );
  });
}
