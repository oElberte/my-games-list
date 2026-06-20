import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/core/utils/app_router.dart';
import 'package:my_games_list/core/widgets/visibility_hero.dart';
import 'package:my_games_list/features/library/bloc/library_bloc.dart';
import 'package:my_games_list/features/library/bloc/library_event.dart';
import 'package:my_games_list/features/library/bloc/library_state.dart';
import 'package:my_games_list/features/library/library_entry_model.dart';

/// Games screen - displays user's game library with filtering and management.
///
/// Features:
/// - View all games in library
/// - Filter by favorites only
/// - Filter by status (playing, finished, etc.)
/// - Add new games via search
/// - Toggle favorites with optimistic UI
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed(AppRouter.searchName),
            tooltip: 'Add Game',
          ),
        ],
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state.isLoading && !state.hasEntries) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == LibraryStatus.failure && !state.hasEntries) {
            return _ErrorView(
              message: state.errorMessage ?? 'Failed to load library',
              onRetry: () {
                if (state.userId != null) {
                  context.read<LibraryBloc>().add(
                    LibraryLoadRequested(userId: state.userId!),
                  );
                }
              },
            );
          }

          return Column(
            children: [
              // Filter chips
              _FilterChips(state: state),
              // Library entries list
              Expanded(
                child: state.filteredEntries.isEmpty
                    ? _EmptyLibraryView(
                        showFavoritesOnly: state.showFavoritesOnly,
                        statusFilter: state.statusFilter,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (state.userId != null) {
                            context.read<LibraryBloc>().add(
                              LibraryRefreshRequested(userId: state.userId!),
                            );
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: state.filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = state.filteredEntries[index];
                            return _LibraryEntryCard(entry: entry);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRouter.searchName),
        icon: const Icon(Icons.add),
        label: const Text('Add Game'),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.state});

  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Favorites filter
            FilterChip(
              selected: state.showFavoritesOnly,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.showFavoritesOnly
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text('Favorites (${state.favoritesCount})'),
                ],
              ),
              onSelected: (selected) {
                context.read<LibraryBloc>().add(
                  LibraryFilterToggled(showFavoritesOnly: selected),
                );
              },
            ),
            const SizedBox(width: 8),
            // Status filters
            ...GameStatus.values.map((status) {
              final count = state.statusCounts[status] ?? 0;
              final isSelected = state.statusFilter == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text('${status.displayName} ($count)'),
                  onSelected: (selected) {
                    context.read<LibraryBloc>().add(
                      LibraryStatusFilterChanged(
                        status: selected ? status : null,
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LibraryEntryCard extends StatelessWidget {
  const _LibraryEntryCard({required this.entry});

  final LibraryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRouter.gameDetailsName,
          pathParameters: {'id': entry.game.igdbId.toString()},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game cover
              VisibilityHero(
                tag: 'game-cover-${entry.game.igdbId}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: entry.game.coverUrl != null
                      ? Image.network(
                          entry.game.coverUrl!,
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 60,
                                height: 80,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.gamepad),
                              ),
                        )
                      : Container(
                          width: 60,
                          height: 80,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.gamepad),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Game info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.game.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(entry.status, theme),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.status.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Platform and playtime
                    Row(
                      children: [
                        if (entry.platform != null) ...[
                          Text(
                            entry.platform!.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Text(' • '),
                        ],
                        Text(
                          entry.playtimeFormatted,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (entry.score != null) ...[
                          const Text(' • '),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber.shade600,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${entry.score}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: entry.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  context.read<LibraryBloc>().add(
                    LibraryToggleFavoriteRequested(entryId: entry.id),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(GameStatus status, ThemeData theme) {
    switch (status) {
      case GameStatus.playing:
        return Colors.green;
      case GameStatus.finished:
        return Colors.blue;
      case GameStatus.planned:
        return Colors.orange;
      case GameStatus.onHold:
        return Colors.purple;
      case GameStatus.dropped:
        return Colors.red;
    }
  }
}

class _EmptyLibraryView extends StatelessWidget {
  const _EmptyLibraryView({required this.showFavoritesOnly, this.statusFilter});

  final bool showFavoritesOnly;
  final GameStatus? statusFilter;

  @override
  Widget build(BuildContext context) {
    String message;
    if (showFavoritesOnly) {
      message = 'No favorite games yet.\nTap the heart icon to add favorites!';
    } else if (statusFilter != null) {
      message =
          'No ${statusFilter!.displayName.toLowerCase()} games.\nAdd games with this status to see them here.';
    } else {
      message =
          'Your library is empty.\nStart adding games to track your collection!';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.pushNamed(AppRouter.searchName),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
