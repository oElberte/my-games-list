import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/blocs/home_bloc.dart';
import 'package:my_games_list/blocs/home_event.dart';
import 'package:my_games_list/blocs/home_state.dart';

import '../mocks/mock_services.dart';

void main() {
  group('HomeBloc', () {
    late MockLocalStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockLocalStorageService();
    });

    test('initial state has empty items and favorites', () {
      final homeBloc = HomeBloc(mockStorageService);
      expect(homeBloc.state.items, isEmpty);
      expect(homeBloc.state.favoriteItemIds, isEmpty);
      homeBloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      'emits state with items and empty favorites when initialized',
      build: () {
        mockStorageService.setStringListReturn(null);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) => bloc.add(const HomeInitialized()),
      expect: () => [
        predicate<HomeState>((state) {
          return state.items.length == 5 &&
              state.favoriteItemIds.isEmpty &&
              state.items.first.name ==
                  'The Legend of Zelda: Breath of the Wild' &&
              state.items.last.name == 'The Witcher 3: Wild Hunt';
        }),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'loads favorites from storage when initialized',
      build: () {
        mockStorageService.setStringListReturn(['1', '3']);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) => bloc.add(const HomeInitialized()),
      expect: () => [
        predicate<HomeState>((state) {
          return state.items.length == 5 &&
              state.favoriteItemIds.length == 2 &&
              state.favoriteItemIds.contains('1') &&
              state.favoriteItemIds.contains('3');
        }),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles missing favorites gracefully',
      build: () {
        mockStorageService.setStringListReturn(null);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) => bloc.add(const HomeInitialized()),
      expect: () => [
        predicate<HomeState>((state) {
          return state.items.length == 5 && state.favoriteItemIds.isEmpty;
        }),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'toggles favorite correctly when adding',
      build: () => HomeBloc(mockStorageService),
      seed: () => const HomeState(
        items: [
          // Add a simple item for testing
        ],
        favoriteItemIds: [],
      ),
      act: (bloc) => bloc.add(const HomeToggleFavorite('1')),
      expect: () => [
        predicate<HomeState>((state) {
          return state.favoriteItemIds.contains('1');
        }),
      ],
      verify: (_) {
        expect(
          mockStorageService.setStringListCallHistory.length,
          greaterThan(0),
        );
      },
    );

    blocTest<HomeBloc, HomeState>(
      'toggles favorite correctly when removing',
      build: () => HomeBloc(mockStorageService),
      seed: () => const HomeState(items: [], favoriteItemIds: ['1']),
      act: (bloc) => bloc.add(const HomeToggleFavorite('1')),
      expect: () => [
        predicate<HomeState>((state) {
          return !state.favoriteItemIds.contains('1');
        }),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'saves favorites to storage when toggled',
      build: () {
        mockStorageService.setStringListReturn(null);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) async {
        bloc.add(const HomeInitialized());
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('1'));
      },
      skip: 1, // Skip the ijnitialization state
      expect: () => [
        predicate<HomeState>((state) {
          return state.favoriteItemIds.contains('1');
        }),
      ],
      verify: (_) {
        expect(
          mockStorageService.setStringListCallHistory.last['key'],
          equals('favorite_items'),
        );
      },
    );

    blocTest<HomeBloc, HomeState>(
      'returns correct favorite items',
      build: () {
        mockStorageService.setStringListReturn(['1', '3']);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) => bloc.add(const HomeInitialized()),
      expect: () => [
        predicate<HomeState>((state) {
          final favoriteItems = state.favoriteItems;
          return favoriteItems.length == 2 &&
              favoriteItems.any((item) => item.id == '1') &&
              favoriteItems.any((item) => item.id == '3');
        }),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles multiple favorite toggles correctly',
      build: () {
        mockStorageService.setStringListReturn(null);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) async {
        bloc.add(const HomeInitialized());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('1'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('2'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('3'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('2'));
      },
      skip: 4, // Skip to the final state after all toggles
      expect: () => [
        predicate<HomeState>((state) {
          return state.favoriteItemIds.length == 2 &&
              state.isFavorite('1') &&
              !state.isFavorite('2') &&
              state.isFavorite('3');
        }),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'isFavorite method works correctly',
      build: () {
        mockStorageService.setStringListReturn(['1']);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) => bloc.add(const HomeInitialized()),
      verify: (bloc) {
        expect(bloc.state.isFavorite('1'), isTrue);
        expect(bloc.state.isFavorite('2'), isFalse);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'favoriteItems updates reactively',
      build: () {
        mockStorageService.setStringListReturn(null);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) async {
        bloc.add(const HomeInitialized());
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('1'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('2'));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('1'));
      },
      skip: 3, // Skip to final state
      expect: () => [
        predicate<HomeState>((state) {
          return state.favoriteItems.length == 1 &&
              state.favoriteItems.first.id == '2';
        }),
      ],
    );
  });
}
