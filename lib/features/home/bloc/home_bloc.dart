import 'package:bloc/bloc.dart';
import 'package:my_games_list/core/data/services/storage/local_storage_service.dart';
import 'package:my_games_list/features/home/bloc/home_event.dart';
import 'package:my_games_list/features/home/bloc/home_state.dart';
import 'package:my_games_list/features/home/item_model.dart';

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
        name: 'Tesla Model 3',
        description: 'All-electric sedan with cutting-edge technology.',
        imageUrl: 'https://example.com/tesla.jpg',
      ),
      const Item(
        id: '2',
        name: 'BMW M4',
        description: 'High-performance luxury coupe.',
        imageUrl: 'https://example.com/bmw.jpg',
      ),
      const Item(
        id: '3',
        name: 'Audi RS6',
        description: 'High-performance station wagon.',
        imageUrl: 'https://example.com/audi.jpg',
      ),
      const Item(
        id: '4',
        name: 'Porsche 911',
        description: 'Iconic sports car with legendary handling.',
        imageUrl: 'https://example.com/porsche.jpg',
      ),
      const Item(
        id: '5',
        name: 'Ford Mustang',
        description: 'Classic American muscle car.',
        imageUrl: 'https://example.com/mustang.jpg',
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
