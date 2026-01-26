import 'package:equatable/equatable.dart';

/// Base class for game details events.
abstract class GameDetailsEvent extends Equatable {
  const GameDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request loading game details.
class GameDetailsLoadRequested extends GameDetailsEvent {
  const GameDetailsLoadRequested(this.gameId);

  final int gameId;

  @override
  List<Object?> get props => [gameId];
}
