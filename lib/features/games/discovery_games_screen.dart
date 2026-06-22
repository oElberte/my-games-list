import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_bloc.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_event.dart';
import 'package:my_games_list/features/games/bloc/discovery_games_state.dart';
import 'package:my_games_list/features/games/discovery_game_model.dart';
import 'package:my_games_list/features/games/widgets/discovery_game_tile.dart';

/// Full screen for viewing all discovery games with grid/list toggle and infinite scroll
class DiscoveryGamesScreen extends StatefulWidget {
  const DiscoveryGamesScreen({required this.discoveryType, super.key});

  final DiscoveryType discoveryType;

  @override
  State<DiscoveryGamesScreen> createState() => _DiscoveryGamesScreenState();
}

class _DiscoveryGamesScreenState extends State<DiscoveryGamesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<DiscoveryGamesBloc>().add(const DiscoveryGamesLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger at 90% scroll
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryGamesBloc, DiscoveryGamesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.discoveryType.localizedName(context)),
            actions: [
              IconButton(
                icon: Icon(
                  state.isGridView ? Icons.view_list : Icons.grid_view,
                ),
                tooltip: state.isGridView
                    ? context.l10n.switchToList
                    : context.l10n.switchToGrid,
                onPressed: () => context.read<DiscoveryGamesBloc>().add(
                  const DiscoveryGamesViewModeToggled(),
                ),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DiscoveryGamesState state) {
    final typeState = state.getStateForType(widget.discoveryType);

    if (typeState.isLoading && !typeState.hasGames) {
      return const Center(child: CircularProgressIndicator());
    }

    if (typeState.status == DiscoveryGamesStatus.failure &&
        !typeState.hasGames) {
      return _ErrorView(
        message: context.l10n.failedToLoadGames,
        onRetry: () => context.read<DiscoveryGamesBloc>().add(
          DiscoveryGamesLoadRequested(widget.discoveryType),
        ),
      );
    }

    if (!typeState.hasGames) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DiscoveryGamesBloc>().add(
          const DiscoveryGamesRefreshRequested(),
        );
        // Wait for the bloc to finish loading
        await context.read<DiscoveryGamesBloc>().stream.firstWhere(
          (s) => !s.getStateForType(widget.discoveryType).isLoading,
        );
      },
      child: state.isGridView
          ? _buildGridView(context, typeState)
          : _buildListView(context, typeState),
    );
  }

  Widget _buildGridView(BuildContext context, DiscoveryTypeState typeState) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < typeState.games.length) {
                return DiscoveryGameTile(game: typeState.games[index]);
              }
              return null;
            }, childCount: typeState.games.length),
          ),
        ),
        if (typeState.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        if (typeState.offsetLimitReached)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  context.l10n.reachedEnd,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
            ),
          ),
        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildListView(BuildContext context, DiscoveryTypeState typeState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: typeState.games.length + (typeState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= typeState.games.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final game = typeState.games[index];
        return DiscoveryGameListTile(game: game);
      },
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              context.l10n.somethingWentWrong,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.browseRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.games_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              context.l10n.noGamesFound,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noGamesInCategory,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
