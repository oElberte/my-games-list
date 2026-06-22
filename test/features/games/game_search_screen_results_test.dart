import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/features/games/bloc/game_search_bloc.dart';
import 'package:my_games_list/features/games/bloc/game_search_event.dart';
import 'package:my_games_list/features/games/bloc/game_search_state.dart';
import 'package:my_games_list/features/games/game_search_screen.dart';
import 'package:my_games_list/features/games/search_game_model.dart';
import 'package:my_games_list/features/games/widgets/game_search_card.dart';
import 'package:my_games_list/l10n/app_localizations.dart';

import '../../mocks/mock_blocs.dart';

class _FakeGameSearchEvent extends Fake implements GameSearchEvent {}

List<SearchGame> _games(int count) {
  return List.generate(
    count,
    (i) => SearchGame(
      id: i,
      name: 'Game $i',
      genres: const [],
      platforms: const [],
    ),
  );
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeGameSearchEvent()));

  group('GameSearchScreen results and interactions', () {
    late MockGameSearchBloc bloc;

    setUp(() {
      bloc = MockGameSearchBloc();
      when(() => bloc.state).thenReturn(const GameSearchState());
    });

    tearDown(() => bloc.close());

    Widget buildSubject() {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider<GameSearchBloc>.value(
          value: bloc,
          child: const GameSearchScreen(),
        ),
      );
    }

    testWidgets('renders the title and the search field', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Search Games'), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Search Games'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('typing a query dispatches GameSearchQueryChanged', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextField), 'zelda');
      await tester.pump();

      final event =
          verify(() => bloc.add(captureAny())).captured.single
              as GameSearchQueryChanged;
      expect(event.query, 'zelda');
    });

    testWidgets('tapping the clear icon dispatches GameSearchClear', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      verify(() => bloc.add(const GameSearchClear())).called(1);
    });

    testWidgets('loading state shows the loading semantics label', (
      tester,
    ) async {
      when(
        () => bloc.state,
      ).thenReturn(const GameSearchState(status: GameSearchStatus.loading));

      await tester.pumpWidget(buildSubject());

      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    });

    testWidgets('failure state shows the error message and icon', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const GameSearchState(
          status: GameSearchStatus.failure,
          errorMessage: 'Search failed',
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Search failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('failure state falls back to the default message', (
      tester,
    ) async {
      when(
        () => bloc.state,
      ).thenReturn(const GameSearchState(status: GameSearchStatus.failure));

      await tester.pumpWidget(buildSubject());

      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('success with results renders a card per game', (tester) async {
      when(() => bloc.state).thenReturn(
        GameSearchState(
          status: GameSearchStatus.success,
          query: 'game',
          games: _games(3),
          hasMore: false,
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(GameSearchCard), findsNWidgets(3));
    });

    testWidgets('a trailing progress indicator shows when more can be loaded', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        GameSearchState(
          status: GameSearchStatus.success,
          query: 'game',
          games: _games(2),
        ),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(GameSearchCard), findsNWidgets(2));
      // 2 result cards + a trailing load-more indicator.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('the offset-limit message shows at the list tail when the '
        'paging limit is reached', (tester) async {
      // The tail item only renders while a load-more is in flight
      // (isLoadingMore); once the offset limit is reached it swaps the spinner
      // for the limit message.
      when(() => bloc.state).thenReturn(
        GameSearchState(
          status: GameSearchStatus.loadingMore,
          query: 'game',
          games: _games(1),
          offsetLimitReached: true,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(
        find.text('Maximum search results reached. Please refine your search.'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
