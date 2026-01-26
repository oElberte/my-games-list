import 'package:equatable/equatable.dart';

abstract class GameSearchEvent extends Equatable {
  const GameSearchEvent();

  @override
  List<Object?> get props => [];
}

class GameSearchQueryChanged extends GameSearchEvent {
  const GameSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class GameSearchLoadMore extends GameSearchEvent {
  const GameSearchLoadMore();
}

class GameSearchClear extends GameSearchEvent {
  const GameSearchClear();
}
