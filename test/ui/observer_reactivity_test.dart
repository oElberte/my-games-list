import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_games_list/stores/home_store.dart';

import '../mocks/mock_services.dart';

void main() {
  group('MobX Observer Reactivity Test', () {
    late MockLocalStorageService mockStorageService;
    late HomeStore homeStore;

    setUp(() {
      mockStorageService = MockLocalStorageService();
      homeStore = HomeStore(mockStorageService);
    });

    testWidgets('Observer should react to favoriteItemIds changes', (
      WidgetTester tester,
    ) async {
      // Create a simple test widget that mimics our home screen pattern
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Observer(
              builder: (context) {
                return ListView.builder(
                  itemCount: homeStore.items.length,
                  itemBuilder: (context, index) {
                    final item = homeStore.items[index];

                    return Observer(
                      builder: (context) {
                        // Direct access to favoriteItemIds like in our fixed code
                        final isFavorite = homeStore.favoriteItemIds.contains(
                          item.id,
                        );

                        return ListTile(
                          title: Text(item.name),
                          trailing: IconButton(
                            key: Key('favorite_button_${item.id}'),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            onPressed: () => homeStore.toggleFavorite(item.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      // Wait for the store to initialize
      await tester.pumpAndSettle();

      // Verify initial state - all should be unfavorited
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(5));
      expect(find.byIcon(Icons.favorite), findsNothing);

      // Tap the first favorite button
      await tester.tap(find.byKey(const Key('favorite_button_1')));

      // This is crucial - pump and settle to let the Observer react
      await tester.pumpAndSettle();

      // Now there should be 1 favorite and 4 unfavorited
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(4));

      // Tap the second favorite button
      await tester.tap(find.byKey(const Key('favorite_button_2')));
      await tester.pumpAndSettle();

      // Now there should be 2 favorites and 3 unfavorited
      expect(find.byIcon(Icons.favorite), findsNWidgets(2));
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(3));

      // Unfavorite the first one
      await tester.tap(find.byKey(const Key('favorite_button_1')));
      await tester.pumpAndSettle();

      // Back to 1 favorite and 4 unfavorited
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(4));
    });

    testWidgets('Observer should react to multiple rapid changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Observer(
              builder: (context) {
                return Column(
                  children: [
                    Text('Favorites: ${homeStore.favoriteItemIds.length}'),
                    ElevatedButton(
                      key: const Key('toggle_multiple'),
                      onPressed: () async {
                        // Toggle multiple favorites rapidly
                        await homeStore.toggleFavorite('1');
                        await homeStore.toggleFavorite('2');
                        await homeStore.toggleFavorite('3');
                      },
                      child: const Text('Toggle Multiple'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state
      expect(find.text('Favorites: 0'), findsOneWidget);

      // Tap the button to toggle multiple favorites
      await tester.tap(find.byKey(const Key('toggle_multiple')));
      await tester.pumpAndSettle();

      // Should show 3 favorites
      expect(find.text('Favorites: 3'), findsOneWidget);
    });
  });
}
