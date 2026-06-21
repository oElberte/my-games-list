import 'package:equatable/equatable.dart';

abstract class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object?> get props => [];
}

class CollectionsLoadRequested extends CollectionsEvent {
  const CollectionsLoadRequested();
}
