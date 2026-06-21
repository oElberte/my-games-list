import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/features/games/bloc/recommendations_bloc.dart';
import 'package:my_games_list/features/games/bloc/recommendations_state.dart';
import 'package:my_games_list/features/games/discovery_game_model.dart';
import 'package:my_games_list/features/games/widgets/discovery_game_tile.dart';

/// Personalized "Recommended for You" row, derived from the user's library
/// genres (GET /games/recommendations). Hidden when there is nothing to show.
class RecommendationsWidget extends StatelessWidget {
  const RecommendationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendationsBloc, RecommendationsState>(
      builder: (context, state) {
        if (!state.hasGames) {
          return const SizedBox.shrink();
        }
        return _Content(games: state.games);
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.games});

  final List<DiscoveryGame> games;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.recommendationsTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: games.length > 20 ? 20 : games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < games.length - 1 ? 12 : 0,
                ),
                child: AspectRatio(
                  aspectRatio: 0.7,
                  child: DiscoveryGameTile(game: game, isCompact: true),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
