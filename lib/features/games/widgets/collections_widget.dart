import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/features/games/bloc/collections_bloc.dart';
import 'package:my_games_list/features/games/bloc/collections_state.dart';
import 'package:my_games_list/features/games/collection_model.dart';
import 'package:my_games_list/features/games/widgets/discovery_game_tile.dart';
import 'package:my_games_list/features/games/widgets/skeletons/discovery_tile_skeleton.dart';

const double _rowHeight = 200;
const double _tileAspectRatio = 0.7;
const int _maxTiles = 20;
// Bound how many collection rows render on the home so editorial content
// doesn't push the primary discovery rows off-screen.
const int _maxCollectionsOnHome = 3;

/// Curated collections rows on the home (GET /home/collections). Collections
/// are editorial/optional content, so the whole block hides when there is
/// nothing to show (loading/empty/error) rather than flashing an empty skeleton.
class CollectionsWidget extends StatelessWidget {
  const CollectionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsBloc, CollectionsState>(
      builder: (context, state) {
        // Drop empty collections before capping so they don't consume a slot.
        final visible = state.collections
            .where((c) => c.games.isNotEmpty)
            .take(_maxCollectionsOnHome)
            .toList();
        if (visible.isEmpty) {
          // Match Trending/Recommendations: shimmer a row while the first load
          // is in flight, then hide entirely on empty/error so editorial
          // content never flashes a placeholder it can't fill.
          if (state.isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: DiscoveryRowSkeleton(),
            );
          }
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final collection in visible)
              _CollectionSection(collection: collection),
          ],
        );
      },
    );
  }
}

class _CollectionSection extends StatelessWidget {
  const _CollectionSection({required this.collection});

  final GameCollection collection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = collection.games.length > _maxTiles
        ? _maxTiles
        : collection.games.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.collections_bookmark_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        collection.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (collection.description != null &&
                        collection.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        collection.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: count,
            itemBuilder: (context, index) {
              final game = collection.games[index];
              return Padding(
                padding: EdgeInsets.only(right: index < count - 1 ? 12 : 0),
                child: AspectRatio(
                  aspectRatio: _tileAspectRatio,
                  // Per-collection Hero prefix so the same game across
                  // collections/rows doesn't collide.
                  child: DiscoveryGameTile(
                    game: game,
                    isCompact: true,
                    heroTagPrefix: 'col-${collection.id}-',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
