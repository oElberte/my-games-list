// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeStore on HomeStoreBase, Store {
  Computed<List<Item>>? _$favoriteItemsComputed;

  @override
  List<Item> get favoriteItems =>
      (_$favoriteItemsComputed ??= Computed<List<Item>>(
        () => super.favoriteItems,
        name: 'HomeStoreBase.favoriteItems',
      )).value;

  late final _$itemsAtom = Atom(name: 'HomeStoreBase.items', context: context);

  @override
  ObservableList<Item> get items {
    _$itemsAtom.reportRead();
    return super.items;
  }

  @override
  set items(ObservableList<Item> value) {
    _$itemsAtom.reportWrite(value, super.items, () {
      super.items = value;
    });
  }

  late final _$favoriteItemIdsAtom = Atom(
    name: 'HomeStoreBase.favoriteItemIds',
    context: context,
  );

  @override
  ObservableList<String> get favoriteItemIds {
    _$favoriteItemIdsAtom.reportRead();
    return super.favoriteItemIds;
  }

  @override
  set favoriteItemIds(ObservableList<String> value) {
    _$favoriteItemIdsAtom.reportWrite(value, super.favoriteItemIds, () {
      super.favoriteItemIds = value;
    });
  }

  late final _$toggleFavoriteAsyncAction = AsyncAction(
    'HomeStoreBase.toggleFavorite',
    context: context,
  );

  @override
  Future<void> toggleFavorite(String itemId) {
    return _$toggleFavoriteAsyncAction.run(() => super.toggleFavorite(itemId));
  }

  late final _$_loadFavoritesAsyncAction = AsyncAction(
    'HomeStoreBase._loadFavorites',
    context: context,
  );

  @override
  Future<void> _loadFavorites() {
    return _$_loadFavoritesAsyncAction.run(() => super._loadFavorites());
  }

  late final _$HomeStoreBaseActionController = ActionController(
    name: 'HomeStoreBase',
    context: context,
  );

  @override
  bool isFavorite(String itemId) {
    final _$actionInfo = _$HomeStoreBaseActionController.startAction(
      name: 'HomeStoreBase.isFavorite',
    );
    try {
      return super.isFavorite(itemId);
    } finally {
      _$HomeStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _initializeMockData() {
    final _$actionInfo = _$HomeStoreBaseActionController.startAction(
      name: 'HomeStoreBase._initializeMockData',
    );
    try {
      return super._initializeMockData();
    } finally {
      _$HomeStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
items: ${items},
favoriteItemIds: ${favoriteItemIds},
favoriteItems: ${favoriteItems}
    ''';
  }
}
