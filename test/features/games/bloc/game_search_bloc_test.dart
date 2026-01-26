import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/features/games/bloc/game_search_bloc.dart';
import 'package:my_games_list/features/games/bloc/game_search_event.dart';
import 'package:my_games_list/features/games/bloc/game_search_state.dart';
import 'package:my_games_list/features/games/search_game_model.dart';
import 'package:my_games_list/features/games/games_repository.dart';

class MockGamesRepository extends Mock implements GamesRepository {}

void main() {
  group('GameSearchBloc', () {
    late MockGamesRepository mockRepository;
    late GameSearchBloc bloc;

    setUp(() {
      mockRepository = MockGamesRepository();
      bloc = GameSearchBloc(gamesRepository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, equals(const GameSearchState()));
      expect(bloc.state.status, equals(GameSearchStatus.initial));
      expect(bloc.state.games, isEmpty);
      expect(bloc.state.query, isEmpty);
    });

    group('GameSearchQueryChanged', () {
      const mockGames = [
        SearchGame(id: 1, name: 'Test Game', genres: [], platforms: []),
      ];

      const mockResponse = SearchGamesResponse(
        games: mockGames,
        totalCount: 1,
        hasMore: false,
        offset: 0,
        limit: 20,
      );

      blocTest<GameSearchBloc, GameSearchState>(
        'emits [loading, success] when query changed with results',
        build: () {
          when(
            () => mockRepository.searchGames(
              any(),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer((_) async => mockResponse);
          return bloc;
        },
        act: (bloc) => bloc.add(const GameSearchQueryChanged('Test')),
        wait: const Duration(milliseconds: 600), // Wait for debounce
        expect: () => [
          predicate<GameSearchState>(
            (state) =>
                state.status == GameSearchStatus.loading &&
                state.query == 'Test' &&
                state.games.isEmpty,
          ),
          predicate<GameSearchState>(
            (state) =>
                state.status == GameSearchStatus.success &&
                state.games.length == 1 &&
                state.games.first.name == 'Test Game',
          ),
        ],
        verify: (_) {
          verify(
            () => mockRepository.searchGames('Test', limit: 20, offset: 0),
          ).called(1);
        },
      );

      blocTest<GameSearchBloc, GameSearchState>(
        'does not emit when query is empty',
        build: () => bloc,
        act: (bloc) => bloc.add(const GameSearchQueryChanged('')),
        wait: const Duration(milliseconds: 100),
        expect: () => [],
        verify: (_) {
          verifyNever(
            () => mockRepository.searchGames(
              any(),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          );
          // State should remain initial
          expect(bloc.state.status, GameSearchStatus.initial);
        },
      );

      blocTest<GameSearchBloc, GameSearchState>(
        'emits failure when repository throws',
        build: () {
          when(
            () => mockRepository.searchGames(
              any(),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenThrow(Exception('Search failed'));
          return bloc;
        },
        act: (bloc) => bloc.add(const GameSearchQueryChanged('Error')),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          predicate<GameSearchState>(
            (state) =>
                state.status == GameSearchStatus.loading &&
                state.query == 'Error',
          ),
          predicate<GameSearchState>(
            (state) =>
                state.status == GameSearchStatus.failure &&
                state.errorMessage != null,
          ),
        ],
      );

      blocTest<GameSearchBloc, GameSearchState>(
        'debounces rapid query changes',
        build: () {
          when(
            () => mockRepository.searchGames(
              any(),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer((_) async => mockResponse);
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const GameSearchQueryChanged('T'));
          await Future<void>.delayed(const Duration(milliseconds: 100));
          bloc.add(const GameSearchQueryChanged('Te'));
          await Future<void>.delayed(const Duration(milliseconds: 100));
          bloc.add(const GameSearchQueryChanged('Tes'));
          await Future<void>.delayed(const Duration(milliseconds: 100));
          bloc.add(const GameSearchQueryChanged('Test'));
        },
        wait: const Duration(milliseconds: 800),
        verify: (_) {
          // Should only call API once with final query after debounce
          verify(
            () => mockRepository.searchGames('Test', limit: 20, offset: 0),
          ).called(1);
        },
      );
    });

    group('GameSearchLoadMore', () {
      final mockGames = List.generate(
        20,
        (i) => SearchGame(
          id: i,
          name: 'Game $i',
          genres: const [],
          platforms: const [],
        ),
      );

      blocTest<GameSearchBloc, GameSearchState>(
        'loads more results when hasMore is true',
        build: () {
          when(
            () => mockRepository.searchGames(
              any(),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenAnswer(
            (_) async => SearchGamesResponse(
              games: mockGames,
              totalCount: 20,
              hasMore: true,
              offset: 20,
              limit: 20,
            ),
          );
          return bloc;
        },
        seed: () => GameSearchState(
          status: GameSearchStatus.success,
          query: 'Test',
          games: mockGames.sublist(0, 10),
          currentOffset: 20,
          hasMore: true,
        ),
        act: (bloc) => bloc.add(const GameSearchLoadMore()),
        expect: () => [
          predicate<GameSearchState>(
            (state) => state.status == GameSearchStatus.loadingMore,
          ),
          predicate<GameSearchState>(
            (state) =>
                state.status == GameSearchStatus.success &&
                state.games.length == 30,
          ),
        ],
      );

      blocTest<GameSearchBloc, GameSearchState>(
        'does not load more when already loading',
        build: () => bloc,
        seed: () => const GameSearchState(
          status: GameSearchStatus.loadingMore,
          query: 'Test',
        ),
        act: (bloc) => bloc.add(const GameSearchLoadMore()),
        expect: () => [],
      );

      blocTest<GameSearchBloc, GameSearchState>(
        'sets offsetLimitReached when offset >= 10000',
        build: () => bloc,
        seed: () => const GameSearchState(
          status: GameSearchStatus.success,
          query: 'Test',
          currentOffset: 10000,
          hasMore: true,
        ),
        act: (bloc) => bloc.add(const GameSearchLoadMore()),
        expect: () => [
          predicate<GameSearchState>(
            (state) =>
                state.offsetLimitReached == true && state.hasMore == false,
          ),
        ],
      );
    });

    group('GameSearchClear', () {
      blocTest<GameSearchBloc, GameSearchState>(
        'resets to initial state',
        build: () => bloc,
        seed: () => const GameSearchState(
          status: GameSearchStatus.success,
          query: 'Test',
          games: [SearchGame(id: 1, name: 'Test', genres: [], platforms: [])],
        ),
        act: (bloc) => bloc.add(const GameSearchClear()),
        expect: () => [const GameSearchState()],
      );
    });

    group('state getters', () {
      test('isLoading returns true when status is loading', () {
        const state = GameSearchState(status: GameSearchStatus.loading);
        expect(state.isLoading, isTrue);
      });

      test('isLoadingMore returns true when status is loadingMore', () {
        const state = GameSearchState(status: GameSearchStatus.loadingMore);
        expect(state.isLoadingMore, isTrue);
      });

      test('hasGames returns true when games list is not empty', () {
        const state = GameSearchState(
          games: [SearchGame(id: 1, name: 'Test', genres: [], platforms: [])],
        );
        expect(state.hasGames, isTrue);
      });

      test(
        'isEmpty returns true when games is empty and status is success',
        () {
          const state = GameSearchState(
            status: GameSearchStatus.success,
            games: [],
          );
          expect(state.isEmpty, isTrue);
        },
      );

      test('canLoadMore returns correct value', () {
        const stateCanLoad = GameSearchState(
          hasMore: true,
          offsetLimitReached: false,
          status: GameSearchStatus.success,
        );
        expect(stateCanLoad.canLoadMore, isTrue);

        const stateCannotLoad = GameSearchState(
          hasMore: false,
          offsetLimitReached: false,
          status: GameSearchStatus.success,
        );
        expect(stateCannotLoad.canLoadMore, isFalse);
      });
    });
  });
}
