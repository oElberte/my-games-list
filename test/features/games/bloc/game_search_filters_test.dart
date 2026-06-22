import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/features/games/bloc/game_search_filters.dart';
import 'package:my_games_list/features/games/search_game_model.dart';

SearchGame _game({
  required int id,
  required String name,
  DateTime? releaseDate,
  List<GameGenre> genres = const [],
  List<GamePlatform> platforms = const [],
}) {
  return SearchGame(
    id: id,
    name: name,
    firstReleaseDate: releaseDate,
    genres: genres,
    platforms: platforms,
  );
}

void main() {
  group('GameSearchFilters.apply sort by date', () {
    test('Newest first orders same-year games by full date, newest first', () {
      final jan = _game(
        id: 1,
        name: 'January',
        releaseDate: DateTime(2020, 1, 15),
      );
      final dec = _game(
        id: 2,
        name: 'December',
        releaseDate: DateTime(2020, 12, 20),
      );

      // Loaded order is January then December; the sort must reorder them.
      const filters = GameSearchFilters(sort: GameSearchSort.yearDesc);
      final result = filters.apply([jan, dec]);

      expect(result.map((g) => g.id).toList(), [dec.id, jan.id]);
    });

    test('Oldest first orders same-year games by full date, oldest first', () {
      final jan = _game(
        id: 1,
        name: 'January',
        releaseDate: DateTime(2020, 1, 15),
      );
      final dec = _game(
        id: 2,
        name: 'December',
        releaseDate: DateTime(2020, 12, 20),
      );

      // Loaded order is December then January; the sort must reorder them.
      const filters = GameSearchFilters(sort: GameSearchSort.yearAsc);
      final result = filters.apply([dec, jan]);

      expect(result.map((g) => g.id).toList(), [jan.id, dec.id]);
    });

    test('games without a release date are pushed last in both directions', () {
      final dated = _game(
        id: 1,
        name: 'Dated',
        releaseDate: DateTime(2020, 6, 1),
      );
      final undated = _game(id: 2, name: 'Undated');

      final desc = const GameSearchFilters(
        sort: GameSearchSort.yearDesc,
      ).apply([undated, dated]);
      expect(desc.map((g) => g.id).toList(), [dated.id, undated.id]);

      final asc = const GameSearchFilters(
        sort: GameSearchSort.yearAsc,
      ).apply([undated, dated]);
      expect(asc.map((g) => g.id).toList(), [dated.id, undated.id]);
    });
  });
}
