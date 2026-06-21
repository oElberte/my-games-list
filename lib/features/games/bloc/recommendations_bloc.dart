import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/features/games/bloc/recommendations_event.dart';
import 'package:my_games_list/features/games/bloc/recommendations_state.dart';
import 'package:my_games_list/features/games/games_repository.dart';

class RecommendationsBloc
    extends Bloc<RecommendationsEvent, RecommendationsState> {
  RecommendationsBloc({required GamesRepository gamesRepository})
    : _gamesRepository = gamesRepository,
      super(const RecommendationsState()) {
    on<RecommendationsLoadRequested>(_onLoadRequested);
  }

  final GamesRepository _gamesRepository;

  Future<void> _onLoadRequested(
    RecommendationsLoadRequested event,
    Emitter<RecommendationsState> emit,
  ) async {
    if (state.status == RecommendationsStatus.loading) return;

    emit(state.copyWith(status: RecommendationsStatus.loading));
    try {
      final games = await _gamesRepository.getRecommendations();
      emit(state.copyWith(status: RecommendationsStatus.success, games: games));
    } catch (e) {
      emit(
        state.copyWith(
          status: RecommendationsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
