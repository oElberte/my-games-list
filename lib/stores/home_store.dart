import 'package:mobx/mobx.dart';

import '../models/item_model.dart';
import '../services/local_storage_service.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  final LocalStorageService _storageService;
  static const String _favoritesKey = 'favorite_items';

  HomeStoreBase(this._storageService) {
    _initializeMockData();
    _loadFavorites();
  }

  @observable
  ObservableList<Item> items = ObservableList<Item>();

  @observable
  ObservableList<String> favoriteItemIds = ObservableList<String>();

  @computed
  List<Item> get favoriteItems =>
      items.where((item) => favoriteItemIds.contains(item.id)).toList();

  @action
  Future<void> toggleFavorite(String itemId) async {
    if (favoriteItemIds.contains(itemId)) {
      favoriteItemIds.remove(itemId);
    } else {
      favoriteItemIds.add(itemId);
    }
    await _saveFavorites();
  }

  bool isFavorite(String itemId) {
    return favoriteItemIds.contains(itemId);
  }

  @action
  void _initializeMockData() {
    items.addAll([
      const Item(
        id: '1',
        name: 'The Legend of Zelda: Breath of the Wild',
        description: 'An open-world action-adventure game.',
        imageUrl: 'https://example.com/zelda.jpg',
      ),
      const Item(
        id: '2',
        name: 'Super Mario Odyssey',
        description: 'A 3D platform game featuring Mario.',
        imageUrl: 'https://example.com/mario.jpg',
      ),
      const Item(
        id: '3',
        name: 'Cyberpunk 2077',
        description: 'A futuristic open-world RPG.',
        imageUrl: 'https://example.com/cyberpunk.jpg',
      ),
      const Item(
        id: '4',
        name: 'God of War',
        description: 'An action-adventure game based on Norse mythology.',
        imageUrl: 'https://example.com/gow.jpg',
      ),
      const Item(
        id: '5',
        name: 'The Witcher 3: Wild Hunt',
        description: 'An open-world fantasy RPG.',
        imageUrl: 'https://example.com/witcher.jpg',
      ),
    ]);
  }

  @action
  Future<void> _loadFavorites() async {
    try {
      final favoritesJson = await _storageService.getStringList(_favoritesKey);
      if (favoritesJson != null) {
        favoriteItemIds.clear();
        favoriteItemIds.addAll(favoritesJson);
      }
    } catch (e) {
      // If there's an error loading favorites, start with empty list
      favoriteItemIds.clear();
    }
  }

  Future<void> _saveFavorites() async {
    await _storageService.setStringList(
      _favoritesKey,
      favoriteItemIds.toList(),
    );
  }
}
