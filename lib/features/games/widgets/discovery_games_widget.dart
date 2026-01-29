import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/core/utils/app_router.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_bloc.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_event.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_state.dart';
import 'package:my_games_list/features/games/discovery_game_model.dart';
import 'package:my_games_list/features/games/widgets/discovery_game_tile.dart';

/// A horizontal scrollable widget displaying discovery games on the home screen
class DiscoveryGamesWidget extends StatelessWidget {
  const DiscoveryGamesWidget({
    required this.discoveryType,
    this.icon,
    super.key,
  });

  final DiscoveryType discoveryType;
  final IconData? icon;

  IconData get _defaultIcon {
    switch (discoveryType) {
      case DiscoveryType.trending:
        return Icons.trending_up;
      case DiscoveryType.indie:
        return Icons.lightbulb_outline;
      case DiscoveryType.upcoming:
        return Icons.schedule;
    }
  }

  Color get _iconColor {
    switch (discoveryType) {
      case DiscoveryType.trending:
        return Colors.orange;
      case DiscoveryType.indie:
        return Colors.purple;
      case DiscoveryType.upcoming:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryGamesBloc, DiscoveryGamesState>(
      builder: (context, state) {
        if (state.isLoading && !state.hasGames) {
          return _WidgetLoading(
            title: discoveryType.displayName,
            icon: icon ?? _defaultIcon,
            iconColor: _iconColor,
          );
        }

        if (state.status == DiscoveryGamesStatus.failure && !state.hasGames) {
          return _WidgetError(
            title: discoveryType.displayName,
            icon: icon ?? _defaultIcon,
            iconColor: _iconColor,
            message: state.errorMessage ?? 'Failed to load games',
            onRetry: () => context.read<DiscoveryGamesBloc>().add(
              DiscoveryGamesLoadRequested(discoveryType),
            ),
          );
        }

        if (!state.hasGames) {
          return const SizedBox.shrink();
        }

        return _WidgetContent(
          title: discoveryType.displayName,
          icon: icon ?? _defaultIcon,
          iconColor: _iconColor,
          games: state.games,
          discoveryType: discoveryType,
        );
      },
    );
  }
}

class _WidgetContent extends StatelessWidget {
  const _WidgetContent({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.games,
    required this.discoveryType,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<DiscoveryGame> games;
  final DiscoveryType discoveryType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with title and see all arrow
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => context.pushNamed(
                  AppRouter.discoveryName,
                  pathParameters: {'type': discoveryType.queryParam},
                ),
                icon: const Text('See All'),
                label: const Icon(Icons.arrow_forward_ios, size: 14),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        // Horizontal scrollable grid
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

class _WidgetLoading extends StatelessWidget {
  const _WidgetLoading({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
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
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < 4 ? 12 : 0),
                child: Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WidgetError extends StatelessWidget {
  const _WidgetError({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String message;
  final VoidCallback onRetry;

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
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(message, style: theme.textTheme.bodyMedium),
                  ),
                  TextButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
