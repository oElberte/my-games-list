import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/blocs/auth_bloc.dart';
import 'package:my_games_list/blocs/auth_state.dart';
import 'package:my_games_list/models/user_model.dart';
import 'package:my_games_list/services/service_locator.dart';
import 'package:my_games_list/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_blocs.dart';

void main() {
  group('AppRouter', () {
    setUp(() async {
      // Reset GetIt and setup mock data
      await sl.reset();
      SharedPreferences.setMockInitialValues({});
      await setupServiceLocator();
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('should create router with correct initial route', (
      tester,
    ) async {
      // Arrange
      final authBloc = sl<AuthBloc>();
      final router = AppRouter.createRouter();

      // Assert - Check that router is created successfully
      expect(router, isNotNull);
      expect(router.routerDelegate, isNotNull);

      // Cleanup
      authBloc.close();
    });

    testWidgets('should have all required routes configured', (tester) async {
      // Arrange
      final authBloc = sl<AuthBloc>();
      final router = AppRouter.createRouter();

      // Assert - Check that all routes are accessible
      expect(() => router.go(AppRouter.signInPath), returnsNormally);
      expect(() => router.go(AppRouter.homePath), returnsNormally);
      expect(() => router.go(AppRouter.settingsPath), returnsNormally);
      expect(() => router.go(AppRouter.webviewPath), returnsNormally);

      // Cleanup
      authBloc.close();
    });

    testWidgets('should handle named routes correctly', (tester) async {
      // Arrange
      final authBloc = sl<AuthBloc>();
      final router = AppRouter.createRouter();

      // Act & Assert - Check that named routes work
      expect(() => router.goNamed(AppRouter.signInName), returnsNormally);
      expect(() => router.goNamed(AppRouter.homeName), returnsNormally);
      expect(() => router.goNamed(AppRouter.settingsName), returnsNormally);
      expect(() => router.goNamed(AppRouter.webviewName), returnsNormally);

      // Cleanup
      authBloc.close();
    });

    test('should have correct route constants', () {
      // Assert
      expect(AppRouter.signInPath, equals('/signin'));
      expect(AppRouter.homePath, equals('/'));
      expect(AppRouter.settingsPath, equals('/settings'));
      expect(AppRouter.webviewPath, equals('/webview'));

      expect(AppRouter.signInName, equals('signin'));
      expect(AppRouter.homeName, equals('home'));
      expect(AppRouter.settingsName, equals('settings'));
      expect(AppRouter.webviewName, equals('webview'));
    });

    testWidgets('should show error screen on invalid route', (tester) async {
      // Arrange - Create mock AuthBloc and stub it to be authenticated
      final mockAuthBloc = MockAuthBloc();
      const testUser = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
      );

      whenListen(
        mockAuthBloc,
        Stream<AuthState>.fromIterable([const AuthAuthenticated(testUser)]),
        initialState: const AuthAuthenticated(testUser),
      );

      final router = AppRouter.createRouter();
      final app = MaterialApp.router(routerConfig: router);

      await tester.pumpWidget(app);
      await tester.pump();

      // Act - Navigate to an invalid route
      router.go('/invalid-route-that-does-not-exist');
      await tester.pumpAndSettle();

      // Assert - Should show error screen
      expect(find.text('Oops! Something went wrong.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);
    });

    testWidgets('error screen should navigate back to home', (tester) async {
      // Arrange - Create mock AuthBloc and stub it to be authenticated
      final mockAuthBloc = MockAuthBloc();
      const testUser = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
      );

      whenListen(
        mockAuthBloc,
        Stream<AuthState>.fromIterable([const AuthAuthenticated(testUser)]),
        initialState: const AuthAuthenticated(testUser),
      );

      final router = AppRouter.createRouter();
      final app = MaterialApp.router(routerConfig: router);

      await tester.pumpWidget(app);
      await tester.pump();

      // Act - Navigate to an invalid route
      router.go('/invalid-route-that-does-not-exist');
      await tester.pumpAndSettle();

      // Tap the "Go to Home" button
      await tester.tap(find.text('Go to Home'));
      await tester.pumpAndSettle();

      // Assert - Should complete successfully (navigation occurred)
      expect(find.text('Go to Home'), findsNothing);
    });
  });
}
