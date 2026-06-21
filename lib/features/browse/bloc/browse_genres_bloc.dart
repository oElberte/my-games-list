import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_event.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_state.dart';
import 'package:my_games_list/features/games/games_repository.dart';

class BrowseGenresBloc extends Bloc<BrowseGenresEvent, BrowseGenresState> {
  BrowseGenresBloc({required GamesRepository gamesRepository})
    : _gamesRepository = gamesRepository,
      super(const BrowseGenresState()) {
    on<BrowseGenresLoadRequested>(_onLoadRequested);
  }

  final GamesRepository _gamesRepository;

  Future<void> _onLoadRequested(
    BrowseGenresLoadRequested event,
    Emitter<BrowseGenresState> emit,
  ) async {
    if (state.status == BrowseGenresStatus.loading) return;

    emit(state.copyWith(status: BrowseGenresStatus.loading));
    try {
      final genres = await _gamesRepository.getGenres();
      emit(state.copyWith(status: BrowseGenresStatus.success, genres: genres));
    } catch (e) {
      emit(
        state.copyWith(
          status: BrowseGenresStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
