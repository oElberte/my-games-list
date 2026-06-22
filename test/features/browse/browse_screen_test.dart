import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/core/services/connectivity_cubit.dart';
import 'package:my_games_list/core/widgets/visibility_hero.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_bloc.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_event.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_state.dart';
import 'package:my_games_list/features/browse/browse_screen.dart';
import 'package:my_games_list/features/games/bloc/collections_bloc.dart';
import 'package:my_games_list/features/games/bloc/collections_event.dart';
import 'package:my_games_list/features/games/bloc/collections_state.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_bloc.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_event.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_state.dart';
import 'package:my_games_list/features/games/collection_model.dart';
import 'package:my_games_list/features/games/discovery_game_model.dart';
import 'package:my_games_list/features/games/game_detail_model.dart';
import 'package:my_games_list/l10n/app_localizations.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MockBrowseGenresBloc
    extends MockBloc<BrowseGenresEvent, BrowseGenresState>
    implements BrowseGenresBloc {}

class MockDiscoveryGamesBloc
    extends MockBloc<DiscoveryGamesEvent, DiscoveryGamesState>
    implements DiscoveryGamesBloc {}

class MockCollectionsBloc extends MockBloc<CollectionsEvent, CollectionsState>
    implements CollectionsBloc {}

class MockConnectivityCubit extends MockCubit<bool>
    implements ConnectivityCubit {}

/// A discovery state holding the same games for both release rows so the
/// Browse releases section renders content for newReleases + comingSoon.
DiscoveryGamesState releasesState({
  DiscoveryGamesStatus status = DiscoveryGamesStatus.success,
  List<DiscoveryGame> games = const [],
}) {
  return DiscoveryGamesState(
    stateByType: {
      DiscoveryType.newReleases: DiscoveryTypeState(
        status: status,
        games: games,
      ),
      DiscoveryType.comingSoon: DiscoveryTypeState(
        status: status,
        games: games,
      ),
    },
    activeDiscoveryType: DiscoveryType.newReleases,
  );
}

void main() {
  late MockBrowseGenresBloc genresBloc;
  late MockDiscoveryGamesBloc discoveryBloc;
  late MockCollectionsBloc collectionsBloc;
  late MockConnectivityCubit connectivity;

  const genres = [Genre(id: 1, name: 'Action'), Genre(id: 2, name: 'RPG')];

  final releaseGames = [
    const DiscoveryGame(
      id: 100,
      name: 'Fresh Drop',
      coverUrl: 'https://example.com/100.jpg',
    ),
    const DiscoveryGame(
      id: 101,
      name: 'Future Hit',
      coverUrl: 'https://example.com/101.jpg',
    ),
  ];

  final collections = [
    const GameCollection(
      id: 'coz',
      slug: 'cozy',
      title: 'Cozy Games',
      games: [
        DiscoveryGame(
          id: 200,
          name: 'Stardew',
          coverUrl: 'https://example.com/200.jpg',
        ),
      ],
    ),
  ];

  setUp(() {
    genresBloc = MockBrowseGenresBloc();
    discoveryBloc = MockDiscoveryGamesBloc();
    collectionsBloc = MockCollectionsBloc();
    connectivity = MockConnectivityCubit();
    when(() => connectivity.state).thenReturn(true);
    // Fire visibility callbacks synchronously so the lazy release rows render.
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  tearDown(() {
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 500,
    );
  });

  Widget buildSubject() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<BrowseGenresBloc>.value(value: genresBloc),
          BlocProvider<DiscoveryGamesBloc>.value(value: discoveryBloc),
          BlocProvider<CollectionsBloc>.value(value: collectionsBloc),
          BlocProvider<ConnectivityCubit>.value(value: connectivity),
        ],
        child: const BrowseScreen(),
      ),
    );
  }

  testWidgets('renders the three section headers', (tester) async {
    when(() => genresBloc.state).thenReturn(
      const BrowseGenresState(
        status: BrowseGenresStatus.success,
        genres: genres,
      ),
    );
    when(() => discoveryBloc.state).thenReturn(releasesState());
    when(() => collectionsBloc.state).thenReturn(const CollectionsState());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Genres'), findsOneWidget);
    expect(find.text('Releases'), findsOneWidget);
    expect(find.text('Collections'), findsOneWidget);
  });

  testWidgets('shows genre cards when genres load', (tester) async {
    when(() => genresBloc.state).thenReturn(
      const BrowseGenresState(
        status: BrowseGenresStatus.success,
        genres: genres,
      ),
    );
    when(() => discoveryBloc.state).thenReturn(releasesState());
    when(() => collectionsBloc.state).thenReturn(const CollectionsState());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('RPG'), findsOneWidget);
  });

  testWidgets('shows genres loading indicator while genres load', (
    tester,
  ) async {
    when(
      () => genresBloc.state,
    ).thenReturn(const BrowseGenresState(status: BrowseGenresStatus.loading));
    when(() => discoveryBloc.state).thenReturn(releasesState());
    when(() => collectionsBloc.state).thenReturn(const CollectionsState());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows genres error with retry on failure', (tester) async {
    when(
      () => genresBloc.state,
    ).thenReturn(const BrowseGenresState(status: BrowseGenresStatus.failure));
    when(() => discoveryBloc.state).thenReturn(releasesState());
    when(() => collectionsBloc.state).thenReturn(const CollectionsState());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(
      find.text("Couldn't load genres. Please try again."),
      findsOneWidget,
    );
  });

  testWidgets('renders release rows with games', (tester) async {
    when(() => genresBloc.state).thenReturn(
      const BrowseGenresState(
        status: BrowseGenresStatus.success,
        genres: genres,
      ),
    );
    when(
      () => discoveryBloc.state,
    ).thenReturn(releasesState(games: releaseGames));
    when(() => collectionsBloc.state).thenReturn(const CollectionsState());

    await tester.pumpWidget(buildSubject());
    // Pump so the lazy rows pick up visibility and render their content.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('New Releases'), findsOneWidget);
    expect(find.text('Coming Soon'), findsOneWidget);
    // The same game appears in both release rows; covers are namespaced by the
    // browse-releases- Hero prefix so they don't collide with the Home tab.
    final heroes = tester
        .widgetList<VisibilityHero>(find.byType(VisibilityHero))
        .map((h) => h.tag)
        .toList();
    expect(heroes, contains('browse-releases-game-cover-100'));
  });

  testWidgets('shows discovery error in the releases section', (tester) async {
    when(() => genresBloc.state).thenReturn(
      const BrowseGenresState(
        status: BrowseGenresStatus.success,
        genres: genres,
      ),
    );
    when(
      () => discoveryBloc.state,
    ).thenReturn(releasesState(status: DiscoveryGamesStatus.failure));
    when(() => collectionsBloc.state).thenReturn(const CollectionsState());

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Failed to load games'), findsWidgets);
  });

  testWidgets('renders collection rows with a browse-namespaced Hero', (
    tester,
  ) async {
    when(() => genresBloc.state).thenReturn(
      const BrowseGenresState(
        status: BrowseGenresStatus.success,
        genres: genres,
      ),
    );
    when(() => discoveryBloc.state).thenReturn(releasesState());
    when(() => collectionsBloc.state).thenReturn(
      CollectionsState(
        status: CollectionsStatus.success,
        collections: collections,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Cozy Games'), findsOneWidget);
    final heroes = tester
        .widgetList<VisibilityHero>(find.byType(VisibilityHero))
        .map((h) => h.tag)
        .toList();
    expect(heroes, contains('browse-col-coz-game-cover-200'));
  });
}
