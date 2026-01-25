import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_games_list/core/data/services/http/i_http_client.dart';
import 'package:my_games_list/core/domain/models/api_error.dart';
import 'package:my_games_list/core/domain/models/api_response.dart';
import 'package:my_games_list/features/games/anticipated_game_model.dart';
import 'package:my_games_list/features/games/games_repository.dart';

class MockHttpClient extends Mock implements IHttpClient {}

void main() {
  late GamesRepository repository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    repository = GamesRepository(httpClient: mockHttpClient);
  });

  group('GamesRepository', () {
    group('getAnticipatedGames', () {
      test('returns list of games on successful response', () async {
        // Arrange
        final mockResponse = {
          'games': [
            {
              'id': 52189,
              'name': 'Grand Theft Auto VI',
              'cover_url':
                  'https://images.igdb.com/igdb/image/upload/t_cover_big/co9rwo.jpg',
              'hypes': 764,
              'first_release_date': 1795046400,
              'platforms': [
                {'id': 169, 'name': 'Xbox Series X|S'},
                {'id': 167, 'name': 'PlayStation 5'},
              ],
            },
            {
              'id': 12345,
              'name': 'Another Game',
              'cover_url': '',
              'hypes': 500,
              'first_release_date': 1800000000,
              'platforms': [],
            },
          ],
        };

        when(
          () => mockHttpClient.get<Map<String, dynamic>>('/games/anticipated'),
        ).thenAnswer((_) async => ApiResponse.success(mockResponse));

        // Act
        final games = await repository.getAnticipatedGames();

        // Assert
        expect(games, isA<List<AnticipatedGame>>());
        expect(games.length, 2);
        expect(games[0].id, 52189);
        expect(games[0].name, 'Grand Theft Auto VI');
        expect(games[0].hypes, 764);
        expect(games[0].platforms.length, 2);
        expect(games[1].id, 12345);
        expect(games[1].platforms, isEmpty);

        verify(
          () => mockHttpClient.get<Map<String, dynamic>>('/games/anticipated'),
        ).called(1);
      });

      test('returns empty list when no games in response', () async {
        // Arrange
        final mockResponse = {'games': <Map<String, dynamic>>[]};

        when(
          () => mockHttpClient.get<Map<String, dynamic>>('/games/anticipated'),
        ).thenAnswer((_) async => ApiResponse.success(mockResponse));

        // Act
        final games = await repository.getAnticipatedGames();

        // Assert
        expect(games, isEmpty);
      });

      test('throws exception on API error', () async {
        // Arrange
        const apiError = ApiError(
          name: 'Error',
          message: 'Service unavailable',
          action: 'Try again later',
          statusCode: 503,
          errorCode: 'error.igdb.token.failed',
        );

        when(
          () => mockHttpClient.get<Map<String, dynamic>>('/games/anticipated'),
        ).thenAnswer((_) async => ApiResponse.failure(apiError));

        // Act & Assert
        expect(
          () => repository.getAnticipatedGames(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('AnticipatedGame', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 52189,
        'name': 'Test Game',
        'cover_url': 'https://example.com/cover.jpg',
        'hypes': 100,
        'first_release_date': 1795046400,
        'platforms': [
          {'id': 1, 'name': 'PC'},
        ],
      };

      final game = AnticipatedGame.fromJson(json);

      expect(game.id, 52189);
      expect(game.name, 'Test Game');
      expect(game.coverUrl, 'https://example.com/cover.jpg');
      expect(game.hypes, 100);
      expect(game.platforms.length, 1);
      expect(game.platforms[0].name, 'PC');
    });

    test('fromJson handles null values', () {
      final json = {
        'id': 1,
        'name': 'Minimal Game',
        'first_release_date': 1795046400,
      };

      final game = AnticipatedGame.fromJson(json);

      expect(game.id, 1);
      expect(game.name, 'Minimal Game');
      expect(game.coverUrl, '');
      expect(game.hypes, 0);
      expect(game.platforms, isEmpty);
    });

    test('countdownText returns correct format for days', () {
      final futureDate = DateTime.now().add(
        const Duration(days: 45, hours: 12, minutes: 30),
      );
      final game = AnticipatedGame(
        id: 1,
        name: 'Test',
        coverUrl: '',
        hypes: 0,
        firstReleaseDate: futureDate,
        platforms: const [],
      );

      expect(game.countdownText, contains('d'));
      expect(game.countdownText, contains('h'));
      expect(game.countdownText, contains('m'));
    });

    test('countdownText returns Released for past dates', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final game = AnticipatedGame(
        id: 1,
        name: 'Test',
        coverUrl: '',
        hypes: 0,
        firstReleaseDate: pastDate,
        platforms: const [],
      );

      expect(game.countdownText, 'Released');
      expect(game.isReleased, true);
    });

    test('platformNames returns comma-separated string', () {
      final game = AnticipatedGame(
        id: 1,
        name: 'Test',
        coverUrl: '',
        hypes: 0,
        firstReleaseDate: DateTime.now().add(const Duration(days: 1)),
        platforms: const [
          GamePlatform(id: 1, name: 'PC'),
          GamePlatform(id: 2, name: 'PlayStation 5'),
        ],
      );

      expect(game.platformNames, 'PC, PlayStation 5');
    });

    test('toJson produces correct output', () {
      final game = AnticipatedGame(
        id: 1,
        name: 'Test',
        coverUrl: 'https://example.com/cover.jpg',
        hypes: 100,
        firstReleaseDate: DateTime.fromMillisecondsSinceEpoch(1795046400000),
        platforms: const [GamePlatform(id: 1, name: 'PC')],
      );

      final json = game.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test');
      expect(json['cover_url'], 'https://example.com/cover.jpg');
      expect(json['hypes'], 100);
      expect(json['first_release_date'], 1795046400);
      expect(json['platforms'], isA<List<dynamic>>());
    });
  });
}
