import 'package:my_games_list/core/data/services/http/i_http_client.dart';
import 'package:my_games_list/features/games/anticipated_game_model.dart';
import 'package:my_games_list/features/games/game_detail_model.dart';
import 'package:my_games_list/features/games/search_game_model.dart';

/// Repository for fetching game-related data from the API
class GamesRepository {
  GamesRepository({required IHttpClient httpClient}) : _httpClient = httpClient;

  final IHttpClient _httpClient;

  /// Fetches the most anticipated upcoming games
  Future<List<AnticipatedGame>> getAnticipatedGames() async {
    final response = await _httpClient.get<Map<String, dynamic>>(
      '/games/anticipated',
    );

    if (response.isError) {
      throw Exception(
        response.error?.userMessage ?? 'Failed to fetch anticipated games',
      );
    }

    final gamesResponse = AnticipatedGamesResponse.fromJson(
      response.dataOrThrow,
    );
    return gamesResponse.games;
  }

  /// Searches for games matching the query with pagination
  Future<SearchGamesResponse> searchGames(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/games/search',
      data: {'query': query, 'limit': limit, 'offset': offset},
    );

    if (response.isError) {
      throw Exception(response.error?.userMessage ?? 'Failed to search games');
    }

    return SearchGamesResponse.fromJson(response.dataOrThrow);
  }

  /// Fetches detailed information about a specific game
  Future<GameDetail> getGameDetails(int id) async {
    final response = await _httpClient.get<Map<String, dynamic>>('/games/$id');

    if (response.isError) {
      throw Exception(
        response.error?.userMessage ?? 'Failed to fetch game details',
      );
    }

    final gameDetailResponse = GameDetailResponse.fromJson(
      response.dataOrThrow,
    );
    return gameDetailResponse.game;
  }
}
