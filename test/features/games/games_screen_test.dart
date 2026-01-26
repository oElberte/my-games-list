import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/features/games/games_screen.dart';

void main() {
  group('GamesScreen', () {
    Widget createGamesScreen() {
      return const MaterialApp(home: GamesScreen());
    }

    testWidgets('should display app bar with title', (tester) async {
      // Act
      await tester.pumpWidget(createGamesScreen());

      // Assert
      expect(find.text('Games'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display games icon', (tester) async {
      // Act
      await tester.pumpWidget(createGamesScreen());

      // Assert
      expect(find.byIcon(Icons.sports_esports), findsOneWidget);
    });

    testWidgets('should display "Coming Soon" message', (tester) async {
      // Act
      await tester.pumpWidget(createGamesScreen());

      // Assert
      expect(find.text('Coming Soon'), findsOneWidget);
    });

    testWidgets('should display description text', (tester) async {
      // Act
      await tester.pumpWidget(createGamesScreen());

      // Assert
      expect(
        find.text(
          'We\'re working on bringing you an amazing games browsing experience!',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should center content vertically', (tester) async {
      // Act
      await tester.pumpWidget(createGamesScreen());

      // Assert
      final column = tester.widget<Column>(
        find.descendant(of: find.byType(Center), matching: find.byType(Column)),
      );
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('should have proper spacing between elements', (tester) async {
      // Act
      await tester.pumpWidget(createGamesScreen());

      // Assert - Check for SizedBox with proper heights
      final sizedBoxes = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(SizedBox),
        ),
      );

      expect(
        sizedBoxes.any((box) => box.height == 24),
        isTrue,
        reason: 'Should have 24px spacing after icon',
      );
      expect(
        sizedBoxes.any((box) => box.height == 16),
        isTrue,
        reason: 'Should have 16px spacing after title',
      );
    });

    testWidgets('should use theme colors for icon', (tester) async {
      // Act
      await tester.pumpWidget(createGamesScreen());

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.sports_esports));
      expect(icon.size, equals(80));
      // Color is set from theme, so it should not be null
      expect(icon.color, isNotNull);
    });

    testWidgets('should use proper text styles', (tester) async {
      // Act
      await tester.pumpWidget(createGamesScreen());
      await tester.pumpAndSettle();

      // Assert - Title should use headlineMedium with bold weight
      final titleText = tester.widget<Text>(find.text('Coming Soon'));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));

      // Description should center text
      final descriptionText = tester.widget<Text>(
        find.text(
          'We\'re working on bringing you an amazing games browsing experience!',
        ),
      );
      expect(descriptionText.textAlign, equals(TextAlign.center));
    });
  });
}
