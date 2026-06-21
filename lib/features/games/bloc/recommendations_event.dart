import 'package:equatable/equatable.dart';

abstract class RecommendationsEvent extends Equatable {
  const RecommendationsEvent();

  @override
  List<Object?> get props => [];
}

class RecommendationsLoadRequested extends RecommendationsEvent {
  const RecommendationsLoadRequested();
}
