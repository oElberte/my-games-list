import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeInitialized extends HomeEvent {
  const HomeInitialized();
}

class HomeToggleFavorite extends HomeEvent {
  const HomeToggleFavorite(this.itemId);
  final String itemId;

  @override
  List<Object?> get props => [itemId];
}
