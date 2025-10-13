import 'package:bloc/bloc.dart';
import 'package:my_games_list/blocs/home_event.dart';
import 'package:my_games_list/blocs/home_state.dart';
import 'package:my_games_list/models/item_model.dart';
import 'package:my_games_list/services/local_storage_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._storageService) : super(const HomeState()) {
    on<HomeInitialized>(_onHomeInitialized);
    on<HomeToggleFavorite>(_onHomeToggleFavorite);
  }
  final LocalStorageService _storageService;
  static const String _favoritesKey = 'favorite_items';

  Future<void> _onHomeInitialized(
    HomeInitialized event,
    Emitter<HomeState> emit,
  ) async {
    // Initialize mock data
    final items = [
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
    ];

    // Load favorites
    try {
      final favoritesJson = await _storageService.getStringList(_favoritesKey);
      final favoriteIds = favoritesJson ?? [];

      emit(state.copyWith(items: items, favoriteItemIds: favoriteIds));
    } catch (e) {
      emit(state.copyWith(items: items, favoriteItemIds: []));
    }
  }

  Future<void> _onHomeToggleFavorite(
    HomeToggleFavorite event,
    Emitter<HomeState> emit,
  ) async {
    final favoriteIds = List<String>.from(state.favoriteItemIds);

    if (favoriteIds.contains(event.itemId)) {
      favoriteIds.remove(event.itemId);
    } else {
      favoriteIds.add(event.itemId);
    }

    await _saveFavorites(favoriteIds);
    emit(state.copyWith(favoriteItemIds: favoriteIds));
  }

  Future<void> _saveFavorites(List<String> favoriteIds) async {
    await _storageService.setStringList(_favoritesKey, favoriteIds);
  }
}
