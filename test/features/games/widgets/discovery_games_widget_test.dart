import 'package:bloc_test/bloc_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/features/games/discovery_game_model.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_bloc.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_event.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_state.dart';
import 'package:my_games_list/features/games/widgets/discovery_game_tile.dart';
import 'package:my_games_list/features/games/widgets/discovery_games_widget.dart';

class MockDiscoveryGamesBloc
    extends MockBloc<DiscoveryGamesEvent, DiscoveryGamesState>
    implements DiscoveryGamesBloc {}

void main() {
  group('DiscoveryGameTile', () {
    const mockGame = DiscoveryGame(
      id: 1942,
      name: 'The Witcher 3: Wild Hunt',
      coverUrl:
          'https://images.igdb.com/igdb/image/upload/t_cover_big/coaarl.jpg',
      totalRating: 92.82,
    );

    const mockGameNoRating = DiscoveryGame(
      id: 1,
      name: 'Test Game',
      coverUrl: 'https://example.com/cover.jpg',
    );

    const mockGameNoCover = DiscoveryGame(
      id: 2,
      name: 'No Cover Game',
      totalRating: 80.0,
    );

    Widget createTile({required DiscoveryGame game}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 140,
            height: 200,
            child: DiscoveryGameTile(game: game),
          ),
        ),
      );
    }

    testWidgets('should display game name', (tester) async {
      await tester.pumpWidget(createTile(game: mockGame));
      await tester.pump();

      expect(find.text('The Witcher 3: Wild Hunt'), findsOneWidget);
    });

    testWidgets('should display rating badge when rating exists', (
      tester,
    ) async {
      await tester.pumpWidget(createTile(game: mockGame));
      await tester.pump();

      expect(find.text('93%'), findsOneWidget);
    });

    testWidgets('should not display rating badge when rating is null', (
      tester,
    ) async {
      await tester.pumpWidget(createTile(game: mockGameNoRating));
      await tester.pump();

      // No rating badge should be shown at all
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('should display cover image when cover URL exists', (
      tester,
    ) async {
      await tester.pumpWidget(createTile(game: mockGame));
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('should display placeholder when no cover URL', (tester) async {
      await tester.pumpWidget(createTile(game: mockGameNoCover));
      await tester.pump();

      // Should show gamepad icon placeholder
      expect(find.byIcon(Icons.gamepad), findsOneWidget);
    });

    testWidgets('should be tappable', (tester) async {
      await tester.pumpWidget(createTile(game: mockGame));
      await tester.pump();

      // Just verify the GestureDetector exists
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });

  group('DiscoveryGameListTile', () {
    const mockGame = DiscoveryGame(
      id: 1942,
      name: 'The Witcher 3: Wild Hunt',
      coverUrl:
          'https://images.igdb.com/igdb/image/upload/t_cover_big/coaarl.jpg',
      totalRating: 92.82,
    );

    Widget createListTile({required DiscoveryGame game}) {
      return MaterialApp(
        home: Scaffold(body: DiscoveryGameListTile(game: game)),
      );
    }

    testWidgets('should display game name', (tester) async {
      await tester.pumpWidget(createListTile(game: mockGame));
      await tester.pump();

      expect(find.text('The Witcher 3: Wild Hunt'), findsOneWidget);
    });

    testWidgets('should display rating badge', (tester) async {
      await tester.pumpWidget(createListTile(game: mockGame));
      await tester.pump();

      expect(find.text('93%'), findsOneWidget);
    });

    testWidgets('should display cover image', (tester) async {
      await tester.pumpWidget(createListTile(game: mockGame));
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });

  group('DiscoveryGamesWidget', () {
    late MockDiscoveryGamesBloc mockBloc;

    final mockGames = [
      const DiscoveryGame(
        id: 1942,
        name: 'The Witcher 3',
        coverUrl: 'https://example.com/cover1.jpg',
        totalRating: 92.82,
      ),
      const DiscoveryGame(
        id: 12345,
        name: 'Another Game',
        coverUrl: 'https://example.com/cover2.jpg',
        totalRating: 85.0,
      ),
    ];

    setUp(() {
      mockBloc = MockDiscoveryGamesBloc();
    });

    Widget createWidget({required DiscoveryGamesState state}) {
      when(() => mockBloc.state).thenReturn(state);

      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<DiscoveryGamesBloc>.value(
            value: mockBloc,
            child: const DiscoveryGamesWidget(
              discoveryType: DiscoveryType.trending,
            ),
          ),
        ),
      );
    }

    testWidgets('should display title based on discovery type', (tester) async {
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(
          DiscoveryGamesState(
            status: DiscoveryGamesStatus.success,
            games: mockGames,
            discoveryType: DiscoveryType.trending,
          ),
        ),
      );

      await tester.pumpWidget(
        createWidget(
          state: DiscoveryGamesState(
            status: DiscoveryGamesStatus.success,
            games: mockGames,
            discoveryType: DiscoveryType.trending,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Trending Now'), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading', (
      tester,
    ) async {
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(
          const DiscoveryGamesState(status: DiscoveryGamesStatus.loading),
        ),
      );

      await tester.pumpWidget(
        createWidget(
          state: const DiscoveryGamesState(
            status: DiscoveryGamesStatus.loading,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should display error message on failure', (tester) async {
      const errorMessage = 'Failed to load games';
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(
          const DiscoveryGamesState(
            status: DiscoveryGamesStatus.failure,
            errorMessage: errorMessage,
          ),
        ),
      );

      await tester.pumpWidget(
        createWidget(
          state: const DiscoveryGamesState(
            status: DiscoveryGamesStatus.failure,
            errorMessage: errorMessage,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should display games when loaded', (tester) async {
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(
          DiscoveryGamesState(
            status: DiscoveryGamesStatus.success,
            games: mockGames,
          ),
        ),
      );

      await tester.pumpWidget(
        createWidget(
          state: DiscoveryGamesState(
            status: DiscoveryGamesStatus.success,
            games: mockGames,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('The Witcher 3'), findsOneWidget);
      expect(find.text('Another Game'), findsOneWidget);
    });

    testWidgets('should display See All button', (tester) async {
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(
          DiscoveryGamesState(
            status: DiscoveryGamesStatus.success,
            games: mockGames,
          ),
        ),
      );

      await tester.pumpWidget(
        createWidget(
          state: DiscoveryGamesState(
            status: DiscoveryGamesStatus.success,
            games: mockGames,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('See All'), findsOneWidget);
    });
  });
}
