import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/blocs/home_bloc.dart';
import 'package:my_games_list/blocs/home_event.dart';
import 'package:my_games_list/blocs/home_state.dart';

import '../mocks/mock_services.dart';

void main() {
  group('HomeBloc Reactivity', () {
    late MockLocalStorageService mockStorageService;
    late HomeBloc homeBloc;

    setUp(() {
      mockStorageService = MockLocalStorageService();
      homeBloc = HomeBloc(mockStorageService);
    });

    tearDown(() {
      homeBloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      'should update favorite status reactively',
      build: () {
        mockStorageService.setStringListReturn(null);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) async {
        bloc.add(const HomeInitialized());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('1'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('1'));
      },
      expect: () => [
        // After initialization
        predicate<HomeState>(
          (state) =>
              state.items.length == 5 &&
              state.favoriteItemIds.isEmpty &&
              !state.isFavorite('1'),
        ),
        // After first toggle (add favorite)
        predicate<HomeState>(
          (state) =>
              state.isFavorite('1') &&
              state.favoriteItemIds.length == 1 &&
              state.favoriteItemIds.contains('1'),
        ),
        // After second toggle (remove favorite)
        predicate<HomeState>(
          (state) => !state.isFavorite('1') && state.favoriteItemIds.isEmpty,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'should track multiple favorites correctly',
      build: () {
        mockStorageService.setStringListReturn(null);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) async {
        bloc.add(const HomeInitialized());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('1'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('3'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('5'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('3'));
      },
      skip: 4, // Skip to final state
      expect: () => [
        predicate<HomeState>(
          (state) =>
              state.favoriteItemIds.length == 2 &&
              state.isFavorite('1') &&
              !state.isFavorite('3') &&
              state.isFavorite('5'),
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'should return correct favorite items',
      build: () {
        mockStorageService.setStringListReturn(null);
        return HomeBloc(mockStorageService);
      },
      act: (bloc) async {
        bloc.add(const HomeInitialized());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('1')); // Zelda
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const HomeToggleFavorite('3')); // Cyberpunk
      },
      skip: 2, // Skip to final state
      expect: () => [
        predicate<HomeState>((state) {
          final favoriteItems = state.favoriteItems;
          return favoriteItems.length == 2 &&
              favoriteItems.any((item) => item.name.contains('Zelda')) &&
              favoriteItems.any((item) => item.name.contains('Cyberpunk'));
        }),
      ],
    );
  });
}
