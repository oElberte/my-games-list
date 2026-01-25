import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/core/utils/service_locator.dart';
import 'package:my_games_list/features/settings/bloc/settings_bloc.dart';
import 'package:my_games_list/features/settings/bloc/settings_event.dart';
import 'package:my_games_list/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MyGamesListApp', () {
    setUp(() async {
      // Reset GetIt and setup mock data
      await sl.reset();
      SharedPreferences.setMockInitialValues({});
      await setupServiceLocator();
    });

    tearDown(() async {
      await sl.reset();
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
      // Since we use onGenerateTitle with localization, we check the Title widget
      expect(find.byType(Title), findsOneWidget);
      final titleWidget = tester.widget<Title>(find.byType(Title));
      expect(titleWidget.title, equals('My Games List'));
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
      // This test will be expanded once we have SettingsBloc fully integrated
      // For now, just ensure the app can be built
      await tester.pumpWidget(const MyGamesListApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets(
      'should not reset navigation when theme changes',
      (tester) async {
        // Arrange - Start the app
        await tester.pumpWidget(const MyGamesListApp());
        await tester.pumpAndSettle();

        // The app starts at sign-in page - check for email field which is unique to sign-in
        expect(find.byType(TextFormField), findsWidgets);

        // Get the Scaffold to verify we're on sign-in screen
        expect(find.byType(Scaffold), findsOneWidget);

        // Act - Toggle dark mode via SettingsBloc
        final context = tester.element(find.byType(MaterialApp));
        final settingsBloc = context.read<SettingsBloc>();

        // Toggle to dark mode
        settingsBloc.add(const SettingsDarkModeSet(true));
        await tester.pumpAndSettle();

        // Assert - Should still have TextFormFields (still on sign-in page, not reset)
        expect(find.byType(TextFormField), findsWidgets);
        expect(find.byType(Scaffold), findsOneWidget);

        // Toggle back to light mode
        settingsBloc.add(const SettingsDarkModeSet(false));
        await tester.pumpAndSettle();

        // Assert - Should still be on sign-in page
        expect(find.byType(TextFormField), findsWidgets);
        expect(find.byType(Scaffold), findsOneWidget);
      },
    );

    testWidgets(
      'should apply dark theme when dark mode is enabled',
      (tester) async {
        // Arrange
        await tester.pumpWidget(const MyGamesListApp());
        await tester.pumpAndSettle();

        // Get initial theme brightness
        var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(
          materialApp.theme?.colorScheme.brightness,
          equals(Brightness.light),
        );

        // Act - Enable dark mode
        final context = tester.element(find.byType(MaterialApp));
        final settingsBloc = context.read<SettingsBloc>();
        settingsBloc.add(const SettingsDarkModeSet(true));
        await tester.pumpAndSettle();

        // Assert - Theme should be dark
        materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(
          materialApp.theme?.colorScheme.brightness,
          equals(Brightness.dark),
        );
      },
    );
  });
}
