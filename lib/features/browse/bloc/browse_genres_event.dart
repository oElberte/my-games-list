import 'package:equatable/equatable.dart';

abstract class BrowseGenresEvent extends Equatable {
  const BrowseGenresEvent();

  @override
  List<Object?> get props => [];
}

class BrowseGenresLoadRequested extends BrowseGenresEvent {
  const BrowseGenresLoadRequested();
}
