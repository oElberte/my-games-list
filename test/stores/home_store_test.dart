import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:my_games_list/stores/home_store.dart';

import '../mocks/mock_services.dart';

void main() {
  group('HomeStore', () {
    late MockLocalStorageService mockStorageService;
    late HomeStore homeStore;

    setUp(() {
      mockStorageService = MockLocalStorageService();
      homeStore = HomeStore(mockStorageService);
    });

    test('should initialize with mock data', () async {
      // Wait for initialization to complete
      await Future.delayed(Duration(milliseconds: 10));

      expect(homeStore.items.length, equals(5));
      expect(
        homeStore.items.first.name,
        equals('The Legend of Zelda: Breath of the Wild'),
      );
      expect(homeStore.items.last.name, equals('The Witcher 3: Wild Hunt'));
    });

    test('should start with empty favorites', () {
      expect(homeStore.favoriteItemIds.isEmpty, isTrue);
      expect(homeStore.favoriteItems.isEmpty, isTrue);
    });

    test('should load favorites from storage', () async {
      mockStorageService.setStringListReturn(['1', '3']);

      final newHomeStore = HomeStore(mockStorageService);
      await Future.delayed(Duration(milliseconds: 10));

      expect(newHomeStore.favoriteItemIds.length, equals(2));
      expect(newHomeStore.favoriteItemIds.contains('1'), isTrue);
      expect(newHomeStore.favoriteItemIds.contains('3'), isTrue);
    });

    test('should handle missing favorites gracefully', () async {
      mockStorageService.setStringListReturn(null);

      final newHomeStore = HomeStore(mockStorageService);
      await Future.delayed(Duration(milliseconds: 10));

      expect(newHomeStore.favoriteItemIds.isEmpty, isTrue);
    });

    test('should toggle favorite correctly', () async {
      const itemId = '1';

      // Initially not favorite
      expect(homeStore.isFavorite(itemId), isFalse);

      // Add to favorites
      await homeStore.toggleFavorite(itemId);
      expect(homeStore.isFavorite(itemId), isTrue);
      expect(homeStore.favoriteItemIds.contains(itemId), isTrue);

      // Remove from favorites
      await homeStore.toggleFavorite(itemId);
      expect(homeStore.isFavorite(itemId), isFalse);
      expect(homeStore.favoriteItemIds.contains(itemId), isFalse);
    });

    test('should save favorites to storage when toggled', () async {
      await homeStore.toggleFavorite('1');

      // Check that setStringList was called (favorites are stored as string list)
      expect(
        mockStorageService.setStringListCallHistory.length,
        greaterThan(0),
      );
      expect(
        mockStorageService.setStringListCallHistory.last['key'],
        equals('favorite_items'),
      );
    });

    test('should return correct favorite items', () async {
      await homeStore.toggleFavorite('1');
      await homeStore.toggleFavorite('3');

      final favoriteItems = homeStore.favoriteItems;
      expect(favoriteItems.length, equals(2));
      expect(favoriteItems.any((item) => item.id == '1'), isTrue);
      expect(favoriteItems.any((item) => item.id == '3'), isTrue);
    });

    test('should be observable', () async {
      var observationCount = 0;
      final dispose = autorun((_) {
        // Access observable properties to track changes
        homeStore.favoriteItemIds.length;
        homeStore.items.length;
        observationCount++;
      });

      // Initial observation
      expect(observationCount, equals(1));

      // Toggle favorite should trigger observation
      await homeStore.toggleFavorite('1');
      expect(observationCount, equals(2));

      dispose();
    });

    test('should handle multiple favorite toggles correctly', () async {
      const itemIds = ['1', '2', '3'];

      // Add all to favorites
      for (final id in itemIds) {
        await homeStore.toggleFavorite(id);
      }

      expect(homeStore.favoriteItemIds.length, equals(3));

      // Remove one
      await homeStore.toggleFavorite('2');
      expect(homeStore.favoriteItemIds.length, equals(2));
      expect(homeStore.isFavorite('1'), isTrue);
      expect(homeStore.isFavorite('2'), isFalse);
      expect(homeStore.isFavorite('3'), isTrue);
    });

    test('computed favoriteItems should update reactively', () async {
      expect(homeStore.favoriteItems.isEmpty, isTrue);

      await homeStore.toggleFavorite('1');
      expect(homeStore.favoriteItems.length, equals(1));
      expect(homeStore.favoriteItems.first.id, equals('1'));

      await homeStore.toggleFavorite('2');
      expect(homeStore.favoriteItems.length, equals(2));

      await homeStore.toggleFavorite('1');
      expect(homeStore.favoriteItems.length, equals(1));
      expect(homeStore.favoriteItems.first.id, equals('2'));
    });
  });
}
