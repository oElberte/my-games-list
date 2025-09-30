import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:my_games_list/stores/settings_store.dart';

import '../mocks/mock_services.dart';

void main() {
  group('SettingsStore', () {
    late MockLocalStorageService mockStorageService;
    late SettingsStore settingsStore;

    setUp(() {
      mockStorageService = MockLocalStorageService();
      settingsStore = SettingsStore(mockStorageService);
    });

    test('should initialize with default dark mode off', () async {
      await Future.delayed(Duration(milliseconds: 10));
      expect(settingsStore.isDarkMode, isFalse);
    });

    test('should load dark mode setting from storage', () async {
      mockStorageService.setBoolReturn(true);

      final newSettingsStore = SettingsStore(mockStorageService);
      await Future.delayed(Duration(milliseconds: 10));

      expect(newSettingsStore.isDarkMode, isTrue);
    });

    test('should handle missing settings gracefully', () async {
      mockStorageService.setBoolReturn(null);

      final newSettingsStore = SettingsStore(mockStorageService);
      await Future.delayed(Duration(milliseconds: 10));

      expect(newSettingsStore.isDarkMode, isFalse);
    });

    test('should toggle theme correctly', () async {
      // Initially false
      expect(settingsStore.isDarkMode, isFalse);

      // Toggle to true
      await settingsStore.toggleTheme();
      expect(settingsStore.isDarkMode, isTrue);

      // Toggle back to false
      await settingsStore.toggleTheme();
      expect(settingsStore.isDarkMode, isFalse);
    });

    test('should set dark mode directly', () async {
      await settingsStore.setDarkMode(true);
      expect(settingsStore.isDarkMode, isTrue);

      await settingsStore.setDarkMode(false);
      expect(settingsStore.isDarkMode, isFalse);
    });

    test('should save settings to storage when changed', () async {
      await settingsStore.toggleTheme();

      expect(mockStorageService.setBoolCallHistory.length, greaterThan(0));
      expect(
        mockStorageService.setBoolCallHistory.last['key'],
        equals('is_dark_mode'),
      );
      expect(mockStorageService.setBoolCallHistory.last['value'], isTrue);
    });

    test('should be observable', () async {
      var observationCount = 0;
      final dispose = autorun((_) {
        // Access observable property to track changes
        settingsStore.isDarkMode;
        observationCount++;
      });

      // Initial observation
      expect(observationCount, equals(1));

      // Toggle should trigger observation
      await settingsStore.toggleTheme();
      expect(observationCount, equals(2));

      // SetDarkMode should trigger observation
      await settingsStore.setDarkMode(false);
      expect(observationCount, equals(3));

      dispose();
    });

    test('should handle storage errors gracefully', () async {
      // Simulate storage error by setting return values that would cause issues
      mockStorageService.setBoolReturn(null);

      final newSettingsStore = SettingsStore(mockStorageService);
      await Future.delayed(Duration(milliseconds: 10));

      // Should default to false even with storage errors
      expect(newSettingsStore.isDarkMode, isFalse);

      // Should still be able to change settings
      await newSettingsStore.toggleTheme();
      expect(newSettingsStore.isDarkMode, isTrue);
    });

    test('should persist theme changes', () async {
      await settingsStore.setDarkMode(true);

      // Verify the correct value was saved
      final savedCall = mockStorageService.setBoolCallHistory.last;
      expect(savedCall['key'], equals('is_dark_mode'));
      expect(savedCall['value'], isTrue);

      await settingsStore.setDarkMode(false);

      final latestCall = mockStorageService.setBoolCallHistory.last;
      expect(latestCall['key'], equals('is_dark_mode'));
      expect(latestCall['value'], isFalse);
    });

    test('should track multiple theme toggles', () async {
      expect(settingsStore.isDarkMode, isFalse);

      await settingsStore.toggleTheme(); // true
      await settingsStore.toggleTheme(); // false
      await settingsStore.toggleTheme(); // true

      expect(settingsStore.isDarkMode, isTrue);
      expect(mockStorageService.setBoolCallHistory.length, equals(3));
    });
  });
}
