import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/core/widgets/shimmer_loading.dart';
import 'package:my_games_list/features/games/bloc/game_search_bloc.dart';
import 'package:my_games_list/features/games/bloc/game_search_event.dart';
import 'package:my_games_list/features/games/bloc/game_search_state.dart';
import 'package:my_games_list/features/games/search_game_model.dart';
import 'package:my_games_list/features/games/widgets/game_search_card.dart';

class GameSearchScreen extends StatefulWidget {
  const GameSearchScreen({super.key});

  @override
  State<GameSearchScreen> createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends State<GameSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<GameSearchBloc>().add(const GameSearchLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.searchGamesTitle)),
      body: Column(
        children: [
          _SearchBar(controller: _searchController),
          Expanded(
            child: BlocBuilder<GameSearchBloc, GameSearchState>(
              builder: (context, state) {
                if (state.status == GameSearchStatus.initial) {
                  return _InitialState();
                }

                if (state.isLoading) {
                  return _LoadingState();
                }

                if (state.status == GameSearchStatus.failure) {
                  return _ErrorState(
                    message:
                        state.errorMessage ??
                        context.l10n.searchGamesErrorMessage,
                  );
                }

                if (state.isEmpty) {
                  return _EmptyState(query: state.query);
                }

                return _SearchResults(
                  games: state.games,
                  hasMore: state.canLoadMore,
                  isLoadingMore: state.isLoadingMore,
                  offsetLimitReached: state.offsetLimitReached,
                  scrollController: _scrollController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: context.l10n.searchGamesHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              context.read<GameSearchBloc>().add(const GameSearchClear());
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        onChanged: (query) {
          context.read<GameSearchBloc>().add(GameSearchQueryChanged(query));
        },
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.games,
    required this.hasMore,
    required this.isLoadingMore,
    required this.offsetLimitReached,
    required this.scrollController,
  });

  final List<SearchGame> games;
  final bool hasMore;
  final bool isLoadingMore;
  final bool offsetLimitReached;
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: games.length + (hasMore || isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == games.length) {
          if (offsetLimitReached) {
            return _OffsetLimitReachedMessage();
          }
          return _LoadingMoreIndicator();
        }
        return GameSearchCard(game: games[index]);
      },
    );
  }
}

class _InitialState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SearchMessageView(
      icon: Icons.search,
      title: context.l10n.searchGamesInitialTitle,
      hint: context.l10n.searchGamesInitialHint,
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.loadingLabel,
      liveRegion: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: ShimmerLoading(
            child: Container(
              // Matches GameSearchCard (120px cover + 12px top/bottom padding).
              height: 144,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return _SearchMessageView(
      icon: Icons.search_off,
      title: context.l10n.searchGamesNoResultsTitle,
      hint: context.l10n.searchGamesNoResults(query),
    );
  }
}

/// Shared friendly placeholder for the search screen's initial and no-results
/// states: a soft icon, a warm headline and a short supporting hint.
class _SearchMessageView extends StatelessWidget {
  const _SearchMessageView({
    required this.icon,
    required this.title,
    required this.hint,
  });

  final IconData icon;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _OffsetLimitReachedMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          context.l10n.searchGamesOffsetLimitReached,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.orange[700]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
