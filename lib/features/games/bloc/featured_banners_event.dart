import 'package:equatable/equatable.dart';

abstract class FeaturedBannersEvent extends Equatable {
  const FeaturedBannersEvent();

  @override
  List<Object?> get props => [];
}

class FeaturedBannersLoadRequested extends FeaturedBannersEvent {
  const FeaturedBannersLoadRequested();
}

class FeaturedBannersRefreshRequested extends FeaturedBannersEvent {
  const FeaturedBannersRefreshRequested();
}
