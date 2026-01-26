import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/features/games/bloc/game_details_event.dart';
import 'package:my_games_list/features/games/bloc/game_details_state.dart';
import 'package:my_games_list/features/games/games_repository.dart';

/// BLoC for managing game details state.
class GameDetailsBloc extends Bloc<GameDetailsEvent, GameDetailsState> {
  GameDetailsBloc({required GamesRepository gamesRepository})
    : _gamesRepository = gamesRepository,
      super(const GameDetailsState()) {
    on<GameDetailsLoadRequested>(_onLoadRequested);
  }

  final GamesRepository _gamesRepository;

  Future<void> _onLoadRequested(
    GameDetailsLoadRequested event,
    Emitter<GameDetailsState> emit,
  ) async {
    emit(state.copyWith(status: GameDetailsStatus.loading));

    try {
      final game = await _gamesRepository.getGameDetails(event.gameId);
      emit(state.copyWith(status: GameDetailsStatus.success, game: game));
    } catch (e) {
      emit(
        state.copyWith(
          status: GameDetailsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
