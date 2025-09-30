import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_games_list/services/service_locator.dart';
import 'package:my_games_list/services/local_storage_service.dart';

void main() {
  group('ServiceLocator', () {
    setUp(() async {
      // Reset GetIt before each test
      await getIt.reset();

      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      // Clean up after each test
      await getIt.reset();
    });

    test('should set up all required services', () async {
      // Act
      await setupServiceLocator();

      // Assert
      expect(getIt.isRegistered<SharedPreferences>(), isTrue);
      expect(getIt.isRegistered<LocalStorageService>(), isTrue);
    });

    test('should be able to retrieve registered services', () async {
      // Arrange
      await setupServiceLocator();

      // Act
      final sharedPrefs = getIt<SharedPreferences>();
      final storageService = getIt<LocalStorageService>();

      // Assert
      expect(sharedPrefs, isNotNull);
      expect(storageService, isNotNull);
      expect(storageService, isA<LocalStorageService>());
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
      expect(getIt.isRegistered<SharedPreferences>(), isTrue);

      // Act
      await resetServiceLocator();

      // Assert
      expect(getIt.isRegistered<SharedPreferences>(), isFalse);
      expect(getIt.isRegistered<LocalStorageService>(), isFalse);
    });

    test('should register the same service instance as singleton', () async {
      // Arrange
      await setupServiceLocator();

      // Act
      final storageService1 = getIt<LocalStorageService>();
      final storageService2 = getIt<LocalStorageService>();

      // Assert - should be the same instance
      expect(identical(storageService1, storageService2), isTrue);
    });
  });
}
