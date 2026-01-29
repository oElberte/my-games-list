import 'package:equatable/equatable.dart';
import 'package:my_games_list/features/games/discovery_game_model.dart';

enum DiscoveryGamesStatus { initial, loading, success, failure, loadingMore }

enum DiscoveryViewMode { grid, list }

class DiscoveryGamesState extends Equatable {
  const DiscoveryGamesState({
    this.status = DiscoveryGamesStatus.initial,
    this.games = const [],
    this.discoveryType = DiscoveryType.trending,
    this.viewMode = DiscoveryViewMode.grid,
    this.errorMessage,
    this.hasMore = true,
    this.currentOffset = 0,
    this.offsetLimitReached = false,
  });

  final DiscoveryGamesStatus status;
  final List<DiscoveryGame> games;
  final DiscoveryType discoveryType;
  final DiscoveryViewMode viewMode;
  final String? errorMessage;
  final bool hasMore;
  final int currentOffset;
  final bool offsetLimitReached;

  bool get isLoading => status == DiscoveryGamesStatus.loading;
  bool get isLoadingMore => status == DiscoveryGamesStatus.loadingMore;
  bool get hasGames => games.isNotEmpty;
  bool get isEmpty => games.isEmpty && status == DiscoveryGamesStatus.success;
  bool get canLoadMore => hasMore && !offsetLimitReached && !isLoadingMore;
  bool get isGridView => viewMode == DiscoveryViewMode.grid;

  DiscoveryGamesState copyWith({
    DiscoveryGamesStatus? status,
    List<DiscoveryGame>? games,
    DiscoveryType? discoveryType,
    DiscoveryViewMode? viewMode,
    String? errorMessage,
    bool? hasMore,
    int? currentOffset,
    bool? offsetLimitReached,
  }) {
    return DiscoveryGamesState(
      status: status ?? this.status,
      games: games ?? this.games,
      discoveryType: discoveryType ?? this.discoveryType,
      viewMode: viewMode ?? this.viewMode,
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
    discoveryType,
    viewMode,
    errorMessage,
    hasMore,
    currentOffset,
    offsetLimitReached,
  ];
}
