import 'package:equatable/equatable.dart';

abstract class BrowseGenreGamesEvent extends Equatable {
  const BrowseGenreGamesEvent();

  @override
  List<Object?> get props => [];
}

class BrowseGenreGamesLoadRequested extends BrowseGenreGamesEvent {
  const BrowseGenreGamesLoadRequested(this.genreId);

  final int genreId;

  @override
  List<Object?> get props => [genreId];
}
