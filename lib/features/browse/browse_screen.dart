import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/core/utils/app_router.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_bloc.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_event.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_state.dart';
import 'package:my_games_list/features/browse/widgets/browse_status_views.dart';
import 'package:my_games_list/features/games/game_detail_model.dart';

/// Public discovery hub: browse the catalogue by genre.
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.browseTitle)),
      body: BlocBuilder<BrowseGenresBloc, BrowseGenresState>(
        builder: (context, state) {
          if (state.isLoading && !state.hasGenres) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BrowseGenresStatus.failure && !state.hasGenres) {
            return BrowseErrorView(
              message: context.l10n.browseGenresError,
              onRetry: () => context.read<BrowseGenresBloc>().add(
                const BrowseGenresLoadRequested(),
              ),
            );
          }

          if (!state.hasGenres) {
            return BrowseEmptyView(
              icon: Icons.category_outlined,
              message: context.l10n.browseGenresEmpty,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<BrowseGenresBloc>()
                ..add(const BrowseGenresLoadRequested());
              await bloc.stream.firstWhere((s) => !s.isLoading);
            },
            child: _GenresGrid(genres: state.genres),
          );
        },
      ),
    );
  }
}

class _GenresGrid extends StatelessWidget {
  const _GenresGrid({required this.genres});

  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900
        ? 4
        : width >= 600
        ? 3
        : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) => _GenreCard(genre: genres[index]),
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({required this.genre});

  final Genre genre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRouter.genreGamesName,
          pathParameters: {'genreId': genre.id.toString()},
          queryParameters: {'name': genre.name},
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              genre.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
