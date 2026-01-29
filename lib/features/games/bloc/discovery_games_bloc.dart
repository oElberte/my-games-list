import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/features/games/games_repository.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_event.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_state.dart';

class DiscoveryGamesBloc
    extends Bloc<DiscoveryGamesEvent, DiscoveryGamesState> {
  DiscoveryGamesBloc({required GamesRepository gamesRepository})
    : _gamesRepository = gamesRepository,
      super(const DiscoveryGamesState()) {
    on<DiscoveryGamesLoadRequested>(_onLoadRequested);
    on<DiscoveryGamesLoadMore>(_onLoadMore);
    on<DiscoveryGamesViewModeToggled>(_onViewModeToggled);
    on<DiscoveryGamesRefreshRequested>(_onRefreshRequested);
  }

  final GamesRepository _gamesRepository;

  static const int _pageSize = 50;
  static const int _maxOffset = 10000;

  Future<void> _onLoadRequested(
    DiscoveryGamesLoadRequested event,
    Emitter<DiscoveryGamesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DiscoveryGamesStatus.loading,
        discoveryType: event.type,
        games: [],
        currentOffset: 0,
        offsetLimitReached: false,
        hasMore: true,
      ),
    );

    try {
      final response = await _gamesRepository.getDiscoveryGames(
        event.type,
        limit: _pageSize,
        offset: 0,
      );

      print(
        'passou aqui hasMore: ${response.hasMore}, $_maxOffset pageSize: $_pageSize',
      );
      emit(
        state.copyWith(
          status: DiscoveryGamesStatus.success,
          games: response.games,
          hasMore: response.hasMore,
          currentOffset: _pageSize,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DiscoveryGamesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    DiscoveryGamesLoadMore event,
    Emitter<DiscoveryGamesState> emit,
  ) async {
    // Prevent duplicate loads
    if (state.isLoadingMore) {
      return;
    }

    // Check if we have more data to load
    if (!state.hasMore || state.offsetLimitReached) {
      return;
    }

    // Check if next offset would exceed limit
    final nextOffset = state.currentOffset;
    if (nextOffset >= _maxOffset) {
      emit(state.copyWith(offsetLimitReached: true, hasMore: false));
      return;
    }

    emit(state.copyWith(status: DiscoveryGamesStatus.loadingMore));

    try {
      final response = await _gamesRepository.getDiscoveryGames(
        state.discoveryType,
        limit: _pageSize,
        offset: nextOffset,
      );

      // Calculate if we can load more
      final newOffset = nextOffset + _pageSize;
      final canLoadMoreAfterThis = response.hasMore && newOffset < _maxOffset;

      emit(
        state.copyWith(
          status: DiscoveryGamesStatus.success,
          games: [...state.games, ...response.games],
          hasMore: canLoadMoreAfterThis,
          currentOffset: newOffset,
          offsetLimitReached: newOffset >= _maxOffset,
        ),
      );
    } catch (e) {
      // On error, revert to success status but keep existing games
      emit(
        state.copyWith(
          status: DiscoveryGamesStatus.success,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onViewModeToggled(
    DiscoveryGamesViewModeToggled event,
    Emitter<DiscoveryGamesState> emit,
  ) {
    final newMode = state.isGridView
        ? DiscoveryViewMode.list
        : DiscoveryViewMode.grid;
    emit(state.copyWith(viewMode: newMode));
  }

  Future<void> _onRefreshRequested(
    DiscoveryGamesRefreshRequested event,
    Emitter<DiscoveryGamesState> emit,
  ) async {
    // Keep existing games visible while refreshing
    emit(
      state.copyWith(
        status: DiscoveryGamesStatus.loading,
        currentOffset: 0,
        offsetLimitReached: false,
        hasMore: true,
      ),
    );

    try {
      final response = await _gamesRepository.getDiscoveryGames(
        state.discoveryType,
        limit: _pageSize,
        offset: 0,
      );

      emit(
        state.copyWith(
          status: DiscoveryGamesStatus.success,
          games: response.games,
          hasMore: response.hasMore,
          currentOffset: _pageSize,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DiscoveryGamesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
