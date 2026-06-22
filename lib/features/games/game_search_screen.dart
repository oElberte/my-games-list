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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            context.l10n.searchGamesInitialMessage,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ShimmerLoading(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            context.l10n.searchGamesNoResults(query),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
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
