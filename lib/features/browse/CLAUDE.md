# Browse Feature

## Overview
The public discovery hub (the "Browse" / "Explorar" tab). Lets users explore the
catalogue independent of their own library, in three scrolling sections:
genres, releases, and curated collections.

## Architecture
- `browse_screen.dart`: the Browse tab — a single `ListView` of three sections:
  - **Genres**: a responsive grid of genre cards (`BrowseGenresBloc`).
  - **Releases**: `LazyDiscoveryGamesWidget` rows for `newReleases` + `comingSoon`
    (reuses the Home `DiscoveryGamesBloc` + discovery widgets).
  - **Collections**: `CollectionsWidget` (reuses the Home `CollectionsBloc`).
- `browse_genre_games_screen.dart`: a pushed screen with top-rated games for one
  genre (route `/browse/genres/:genreId?name=`).
- `bloc/browse_genres_*`: loads the genre list (`GamesRepository.getGenres`).
- `bloc/browse_genre_games_*`: loads games for a genre
  (`GamesRepository.getGamesByGenre` → `/games/discovery?type=by_genre&genre_id=`).

Blocs are provided in `app_router.dart` (the `/browse` shell branch and the
`/browse/genres/:genreId` route). The `/browse` branch owns its **own**
`DiscoveryGamesBloc` and `CollectionsBloc` instances, separate from Home's, so
both tabs stay alive in the indexed stack without sharing state. The `Genre`
model is reused from `features/games/game_detail_model.dart`.

## Hero tags
The Home and Browse branches both live in the same
`StatefulShellRoute.indexedStack` and are kept alive simultaneously, so the same
game showing on both tabs would throw a duplicate Hero tag. Each Browse surface
namespaces its cover Heroes with a Browse-only prefix that the destination
`GameDetailsScreen` receives via the GoRouter `extra` so the transition still
matches the source card:
- Genre games list: `browse-genre-<id>-`.
- Releases rows (`newReleases`/`comingSoon`): `browse-releases-`, threaded into
  `LazyDiscoveryGamesWidget`/`DiscoveryGamesWidget` → `DiscoveryGameTile`.
- Collections rows: `browse-col-<collectionId>-` — the `CollectionsWidget`
  `heroTagPrefix` (`browse-`) is prepended to its per-collection `col-<id>-`
  namespace.

`DiscoveryGamesWidget`, `LazyDiscoveryGamesWidget`, and `CollectionsWidget` all
take an optional `heroTagPrefix` (default `''`, so the Home tab is unchanged).
