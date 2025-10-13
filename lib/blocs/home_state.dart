import 'package:equatable/equatable.dart';
import 'package:my_games_list/models/item_model.dart';

class HomeState extends Equatable {
  const HomeState({this.items = const [], this.favoriteItemIds = const []});
  final List<Item> items;
  final List<String> favoriteItemIds;

  List<Item> get favoriteItems =>
      items.where((item) => favoriteItemIds.contains(item.id)).toList();

  bool isFavorite(String itemId) {
    return favoriteItemIds.contains(itemId);
  }

  HomeState copyWith({List<Item>? items, List<String>? favoriteItemIds}) {
    return HomeState(
      items: items ?? this.items,
      favoriteItemIds: favoriteItemIds ?? this.favoriteItemIds,
    );
  }

  @override
  List<Object?> get props => [items, favoriteItemIds];
}
