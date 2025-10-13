import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/blocs/auth_bloc.dart';
import 'package:my_games_list/blocs/home_bloc.dart';
import 'package:my_games_list/blocs/settings_bloc.dart';
import 'package:my_games_list/services/local_storage_service.dart';
import 'package:my_games_list/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ServiceLocator', () {
    setUp(() async {
      // Reset GetIt before each test
      await sl.reset();

      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      // Clean up after each test
      await sl.reset();
    });

    test('should set up all required services', () async {
      // Act
      await setupServiceLocator();

      // Assert
      expect(sl.isRegistered<SharedPreferences>(), isTrue);
      expect(sl.isRegistered<LocalStorageService>(), isTrue);
      expect(sl.isRegistered<AuthBloc>(), isTrue);
      expect(sl.isRegistered<HomeBloc>(), isTrue);
      expect(sl.isRegistered<SettingsBloc>(), isTrue);
    });

    test('should be able to retrieve registered services', () async {
      // Arrange
      await setupServiceLocator();

      // Act
      final sharedPrefs = sl<SharedPreferences>();
      final storageService = sl<LocalStorageService>();

      // Assert
      expect(sharedPrefs, isNotNull);
      expect(storageService, isNotNull);
      expect(storageService, isA<LocalStorageService>());
    });

    test('should be able to retrieve BLoCs', () async {
      // Arrange
      await setupServiceLocator();

      // Act
      final authBloc = sl<AuthBloc>();
      final homeBloc = sl<HomeBloc>();
      final settingsBloc = sl<SettingsBloc>();

      // Assert
      expect(authBloc, isNotNull);
      expect(authBloc, isA<AuthBloc>());
      expect(homeBloc, isNotNull);
      expect(homeBloc, isA<HomeBloc>());
      expect(settingsBloc, isNotNull);
      expect(settingsBloc, isA<SettingsBloc>());

      // Clean up
      authBloc.close();
      homeBloc.close();
      settingsBloc.close();
    });

    test('should wait for all services to be ready', () async {
      // Arrange
      await setupServiceLocator();

      // Act & Assert - should not throw
      await waitForServicesReady();
    });

    test('should reset all registrations', () async {
      // Arrange
      await setupServiceLocator();
      expect(sl.isRegistered<SharedPreferences>(), isTrue);

      // Act
      await resetServiceLocator();

      // Assert
      expect(sl.isRegistered<SharedPreferences>(), isFalse);
      expect(sl.isRegistered<LocalStorageService>(), isFalse);
      expect(sl.isRegistered<AuthBloc>(), isFalse);
      expect(sl.isRegistered<HomeBloc>(), isFalse);
      expect(sl.isRegistered<SettingsBloc>(), isFalse);
    });

    test('should register the same service instance as singleton', () async {
      // Arrange
      await setupServiceLocator();

      // Act
      final storageService1 = sl<LocalStorageService>();
      final storageService2 = sl<LocalStorageService>();

      // Assert - should be the same instance
      expect(identical(storageService1, storageService2), isTrue);
    });

    test('should register BLoCs as factories', () async {
      // Arrange
      await setupServiceLocator();

      // Act
      final authBloc1 = sl<AuthBloc>();
      final authBloc2 = sl<AuthBloc>();

      // Assert - should be different instances (factory pattern)
      expect(identical(authBloc1, authBloc2), isFalse);

      // Clean up
      authBloc1.close();
      authBloc2.close();
    });
  });
}
