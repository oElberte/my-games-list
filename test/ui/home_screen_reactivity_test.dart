import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/stores/home_store.dart';

import '../mocks/mock_services.dart';

void main() {
  group('HomeStore Reactivity', () {
    late MockLocalStorageService mockStorageService;
    late HomeStore homeStore;

    setUp(() {
      mockStorageService = MockLocalStorageService();
      homeStore = HomeStore(mockStorageService);
    });

    test('should update favorite status reactively', () async {
      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 10));

      // Initially should have 5 items and no favorites
      expect(homeStore.items.length, equals(5));
      expect(homeStore.favoriteItemIds.length, equals(0));
      expect(homeStore.isFavorite('1'), isFalse);

      // Toggle first item as favorite
      await homeStore.toggleFavorite('1');

      // Should now be favorite
      expect(homeStore.isFavorite('1'), isTrue);
      expect(homeStore.favoriteItemIds.length, equals(1));
      expect(homeStore.favoriteItemIds.contains('1'), isTrue);

      // Toggle again to unfavorite
      await homeStore.toggleFavorite('1');

      // Should no longer be favorite
      expect(homeStore.isFavorite('1'), isFalse);
      expect(homeStore.favoriteItemIds.length, equals(0));
    });

    test('should track multiple favorites correctly', () async {
      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 10));

      // Add multiple favorites
      await homeStore.toggleFavorite('1');
      await homeStore.toggleFavorite('3');
      await homeStore.toggleFavorite('5');

      expect(homeStore.favoriteItemIds.length, equals(3));
      expect(homeStore.isFavorite('1'), isTrue);
      expect(homeStore.isFavorite('2'), isFalse);
      expect(homeStore.isFavorite('3'), isTrue);
      expect(homeStore.isFavorite('4'), isFalse);
      expect(homeStore.isFavorite('5'), isTrue);

      // Remove one favorite
      await homeStore.toggleFavorite('3');

      expect(homeStore.favoriteItemIds.length, equals(2));
      expect(homeStore.isFavorite('1'), isTrue);
      expect(homeStore.isFavorite('3'), isFalse);
      expect(homeStore.isFavorite('5'), isTrue);
    });

    test('should return correct favorite items', () async {
      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 10));

      // Add some favorites
      await homeStore.toggleFavorite('1'); // Zelda
      await homeStore.toggleFavorite('3'); // Cyberpunk

      final favoriteItems = homeStore.favoriteItems;
      expect(favoriteItems.length, equals(2));
      expect(favoriteItems.any((item) => item.name.contains('Zelda')), isTrue);
      expect(
        favoriteItems.any((item) => item.name.contains('Cyberpunk')),
        isTrue,
      );
    });
  });
}
