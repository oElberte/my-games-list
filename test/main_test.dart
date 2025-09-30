import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_games_list/main.dart';
import 'package:my_games_list/services/service_locator.dart';

void main() {
  group('MyGamesListApp', () {
    setUp(() async {
      // Reset GetIt and setup mock data
      await getIt.reset();
      SharedPreferences.setMockInitialValues({});
      await setupServiceLocator();
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('should initialize and display app correctly', (tester) async {
      // Act
      await tester.pumpWidget(const MyGamesListApp());
      await tester.pumpAndSettle();

      // Assert - App should be created and MaterialApp should be present
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should have correct app title', (tester) async {
      // Arrange
      await tester.pumpWidget(const MyGamesListApp());
      await tester.pumpAndSettle();

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('My Games List'));
    });

    testWidgets('should not show debug banner', (tester) async {
      // Arrange
      await tester.pumpWidget(const MyGamesListApp());
      await tester.pumpAndSettle();

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('should use Material 3 design', (tester) async {
      // Arrange
      await tester.pumpWidget(const MyGamesListApp());
      await tester.pumpAndSettle();

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, isTrue);
    });

    testWidgets('should react to theme changes', (tester) async {
      // This test will be expanded once we have SettingsStore implemented
      // For now, just ensure the app can be built
      await tester.pumpWidget(const MyGamesListApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
