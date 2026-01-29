import 'package:equatable/equatable.dart';
import 'package:my_games_list/features/games/discovery_game_model.dart';

enum DiscoveryGamesStatus { initial, loading, success, failure, loadingMore }

enum DiscoveryViewMode { grid, list }

/// State for a single discovery type
class DiscoveryTypeState extends Equatable {
  const DiscoveryTypeState({
    this.status = DiscoveryGamesStatus.initial,
    this.games = const [],
    this.errorMessage,
    this.hasMore = true,
    this.currentOffset = 0,
    this.offsetLimitReached = false,
  });

  final DiscoveryGamesStatus status;
  final List<DiscoveryGame> games;
  final String? errorMessage;
  final bool hasMore;
  final int currentOffset;
  final bool offsetLimitReached;

  bool get isLoading => status == DiscoveryGamesStatus.loading;
  bool get isLoadingMore => status == DiscoveryGamesStatus.loadingMore;
  bool get hasGames => games.isNotEmpty;
  bool get isEmpty => games.isEmpty && status == DiscoveryGamesStatus.success;
  bool get canLoadMore => hasMore && !offsetLimitReached && !isLoadingMore;

  DiscoveryTypeState copyWith({
    DiscoveryGamesStatus? status,
    List<DiscoveryGame>? games,
    String? errorMessage,
    bool? hasMore,
    int? currentOffset,
    bool? offsetLimitReached,
  }) {
    return DiscoveryTypeState(
      status: status ?? this.status,
      games: games ?? this.games,
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
    errorMessage,
    hasMore,
    currentOffset,
    offsetLimitReached,
  ];
}

/// Main state that holds state for all discovery types
class DiscoveryGamesState extends Equatable {
  const DiscoveryGamesState({
    this.stateByType = const {},
    this.viewMode = DiscoveryViewMode.grid,
    // Legacy fields for backward compatibility with discovery screen
    this.activeDiscoveryType = DiscoveryType.trending,
  });

  /// Factory constructor for backward compatibility with tests and legacy code
  /// Allows creating state with legacy parameters that get mapped to the new structure
  factory DiscoveryGamesState.withLegacyParams({
    DiscoveryGamesStatus status = DiscoveryGamesStatus.initial,
    List<DiscoveryGame> games = const [],
    String? errorMessage,
    bool hasMore = true,
    int currentOffset = 0,
    bool offsetLimitReached = false,
    DiscoveryViewMode viewMode = DiscoveryViewMode.grid,
    DiscoveryType discoveryType = DiscoveryType.trending,
  }) {
    final typeState = DiscoveryTypeState(
      status: status,
      games: games,
      errorMessage: errorMessage,
      hasMore: hasMore,
      currentOffset: currentOffset,
      offsetLimitReached: offsetLimitReached,
    );
    return DiscoveryGamesState(
      stateByType: {discoveryType: typeState},
      viewMode: viewMode,
      activeDiscoveryType: discoveryType,
    );
  }

  /// State for each discovery type
  final Map<DiscoveryType, DiscoveryTypeState> stateByType;
  final DiscoveryViewMode viewMode;

  /// The currently active discovery type (for discovery screen)
  final DiscoveryType activeDiscoveryType;

  /// Get state for a specific discovery type
  DiscoveryTypeState getStateForType(DiscoveryType type) {
    return stateByType[type] ?? const DiscoveryTypeState();
  }

  // Legacy getters for backward compatibility (use activeDiscoveryType)
  DiscoveryGamesStatus get status =>
      getStateForType(activeDiscoveryType).status;
  List<DiscoveryGame> get games => getStateForType(activeDiscoveryType).games;
  DiscoveryType get discoveryType => activeDiscoveryType;
  String? get errorMessage => getStateForType(activeDiscoveryType).errorMessage;
  bool get hasMore => getStateForType(activeDiscoveryType).hasMore;
  int get currentOffset => getStateForType(activeDiscoveryType).currentOffset;
  bool get offsetLimitReached =>
      getStateForType(activeDiscoveryType).offsetLimitReached;

  bool get isLoading => getStateForType(activeDiscoveryType).isLoading;
  bool get isLoadingMore => getStateForType(activeDiscoveryType).isLoadingMore;
  bool get hasGames => getStateForType(activeDiscoveryType).hasGames;
  bool get isEmpty => getStateForType(activeDiscoveryType).isEmpty;
  bool get canLoadMore => getStateForType(activeDiscoveryType).canLoadMore;
  bool get isGridView => viewMode == DiscoveryViewMode.grid;

  /// Update state for a specific discovery type
  DiscoveryGamesState updateTypeState(
    DiscoveryType type,
    DiscoveryTypeState Function(DiscoveryTypeState) update,
  ) {
    final currentTypeState = getStateForType(type);
    final newTypeState = update(currentTypeState);
    return DiscoveryGamesState(
      stateByType: {...stateByType, type: newTypeState},
      viewMode: viewMode,
      activeDiscoveryType: activeDiscoveryType,
    );
  }

  DiscoveryGamesState copyWith({
    Map<DiscoveryType, DiscoveryTypeState>? stateByType,
    DiscoveryViewMode? viewMode,
    DiscoveryType? activeDiscoveryType,
    // Legacy fields - update the active discovery type's state
    DiscoveryGamesStatus? status,
    List<DiscoveryGame>? games,
    String? errorMessage,
    bool? hasMore,
    int? currentOffset,
    bool? offsetLimitReached,
  }) {
    var newStateByType = stateByType ?? this.stateByType;
    final newActiveType = activeDiscoveryType ?? this.activeDiscoveryType;

    // If legacy fields are provided, update the active type's state
    if (status != null ||
        games != null ||
        errorMessage != null ||
        hasMore != null ||
        currentOffset != null ||
        offsetLimitReached != null) {
      final currentTypeState =
          newStateByType[newActiveType] ?? const DiscoveryTypeState();
      final updatedTypeState = currentTypeState.copyWith(
        status: status,
        games: games,
        errorMessage: errorMessage,
        hasMore: hasMore,
        currentOffset: currentOffset,
        offsetLimitReached: offsetLimitReached,
      );
      newStateByType = {...newStateByType, newActiveType: updatedTypeState};
    }

    return DiscoveryGamesState(
      stateByType: newStateByType,
      viewMode: viewMode ?? this.viewMode,
      activeDiscoveryType: newActiveType,
    );
  }

  @override
  List<Object?> get props => [stateByType, viewMode, activeDiscoveryType];
}
