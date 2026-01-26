import 'package:equatable/equatable.dart';
import 'package:my_games_list/features/games/search_game_model.dart';

enum GameSearchStatus { initial, loading, success, failure, loadingMore }

class GameSearchState extends Equatable {
  const GameSearchState({
    this.status = GameSearchStatus.initial,
    this.games = const [],
    this.query = '',
    this.errorMessage,
    this.hasMore = true,
    this.currentOffset = 0,
    this.offsetLimitReached = false,
  });

  final GameSearchStatus status;
  final List<SearchGame> games;
  final String query;
  final String? errorMessage;
  final bool hasMore;
  final int currentOffset;
  final bool offsetLimitReached;

  bool get isLoading => status == GameSearchStatus.loading;
  bool get isLoadingMore => status == GameSearchStatus.loadingMore;
  bool get hasGames => games.isNotEmpty;
  bool get isEmpty => games.isEmpty && status == GameSearchStatus.success;
  bool get canLoadMore => hasMore && !offsetLimitReached && !isLoadingMore;

  GameSearchState copyWith({
    GameSearchStatus? status,
    List<SearchGame>? games,
    String? query,
    String? errorMessage,
    bool? hasMore,
    int? currentOffset,
    bool? offsetLimitReached,
  }) {
    return GameSearchState(
      status: status ?? this.status,
      games: games ?? this.games,
      query: query ?? this.query,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      offsetLimitReached: offsetLimitReached ?? this.offsetLimitReached,
    );
  }

  @override
  List<Object?> get props => [
    status,
    games,
    query,
    errorMessage,
    hasMore,
    currentOffset,
    offsetLimitReached,
  ];
}
