import 'package:equatable/equatable.dart';

/// Base class for anticipated games events
abstract class AnticipatedGamesEvent extends Equatable {
  const AnticipatedGamesEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the anticipated games should be loaded
class AnticipatedGamesLoadRequested extends AnticipatedGamesEvent {
  const AnticipatedGamesLoadRequested();
}

/// Event triggered when the user requests a refresh
class AnticipatedGamesRefreshRequested extends AnticipatedGamesEvent {
  const AnticipatedGamesRefreshRequested();
}

/// Event triggered to update the countdown timers
class AnticipatedGamesCountdownTick extends AnticipatedGamesEvent {
  const AnticipatedGamesCountdownTick();
}
