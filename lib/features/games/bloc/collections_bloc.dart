import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/features/games/bloc/collections_event.dart';
import 'package:my_games_list/features/games/bloc/collections_state.dart';
import 'package:my_games_list/features/games/i_games_repository.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  CollectionsBloc({required IGamesRepository gamesRepository})
    : _gamesRepository = gamesRepository,
      super(const CollectionsState()) {
    on<CollectionsLoadRequested>(_onLoadRequested);
  }

  final IGamesRepository _gamesRepository;

  Future<void> _onLoadRequested(
    CollectionsLoadRequested event,
    Emitter<CollectionsState> emit,
  ) async {
    if (state.status == CollectionsStatus.loading) return;

    emit(state.copyWith(status: CollectionsStatus.loading));
    try {
      final collections = await _gamesRepository.getCollections();
      emit(
        state.copyWith(
          status: CollectionsStatus.success,
          collections: collections,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CollectionsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
