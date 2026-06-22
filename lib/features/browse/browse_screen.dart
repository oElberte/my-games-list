import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/core/utils/app_router.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_bloc.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_event.dart';
import 'package:my_games_list/features/browse/bloc/browse_genres_state.dart';
import 'package:my_games_list/features/browse/widgets/browse_status_views.dart';
import 'package:my_games_list/features/games/discovery_game_model.dart';
import 'package:my_games_list/features/games/game_detail_model.dart';
import 'package:my_games_list/features/games/widgets/collections_widget.dart';
import 'package:my_games_list/features/games/widgets/discovery_games_widget.dart';

/// Public discovery hub: browse the catalogue by genre, then explore new
/// releases and curated collections. Genres, releases and collections each
/// render as their own section in a single scroll view.
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  /// Hero namespaces distinct from the Home tab's rows. Both the Home and
  /// Browse branches live in the same [StatefulShellRoute.indexedStack] and are
  /// kept alive simultaneously, so the same game appearing on both tabs would
  /// throw a duplicate Hero tag without these prefixes.
  static const String _releasesHeroPrefix = 'browse-releases-';
  static const String _collectionsHeroPrefix = 'browse-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.browseTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          final bloc = context.read<BrowseGenresBloc>()
            ..add(const BrowseGenresLoadRequested());
          await bloc.stream.firstWhere((s) => !s.isLoading);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            _GenresSection(),
            SizedBox(height: 8),
            _ReleasesSection(),
            SizedBox(height: 8),
            _CollectionsSection(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _GenresSection extends StatelessWidget {
  const _GenresSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseGenresBloc, BrowseGenresState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: context.l10n.browseGenresSection),
            _GenresBody(state: state),
          ],
        );
      },
    );
  }
}

class _GenresBody extends StatelessWidget {
  const _GenresBody({required this.state});

  final BrowseGenresState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasGenres) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
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

    return _GenresGrid(genres: state.genres);
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
      child: Semantics(
        label: context.l10n.genreCardLabel(genre.name),
        button: true,
        onTap: () => context.pushNamed(
          AppRouter.genreGamesName,
          pathParameters: {'genreId': genre.id.toString()},
          queryParameters: {'name': genre.name},
        ),
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
      ),
    );
  }
}

/// New releases + coming soon rows, reusing the Home discovery widgets but
/// with a Browse-only Hero namespace so covers don't collide with Home.
class _ReleasesSection extends StatelessWidget {
  const _ReleasesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: context.l10n.browseReleasesSection),
        const LazyDiscoveryGamesWidget(
          discoveryType: DiscoveryType.newReleases,
          heroTagPrefix: BrowseScreen._releasesHeroPrefix,
        ),
        const SizedBox(height: 8),
        const LazyDiscoveryGamesWidget(
          discoveryType: DiscoveryType.comingSoon,
          heroTagPrefix: BrowseScreen._releasesHeroPrefix,
        ),
      ],
    );
  }
}

/// Curated collections rows, reusing the Home collections widget with a
/// Browse-only Hero namespace.
class _CollectionsSection extends StatelessWidget {
  const _CollectionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: context.l10n.browseCollectionsSection),
        const CollectionsWidget(
          heroTagPrefix: BrowseScreen._collectionsHeroPrefix,
        ),
      ],
    );
  }
}
