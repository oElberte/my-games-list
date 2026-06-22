# Browse Feature

## Overview
The public discovery hub (the "Browse" / "Explorar" tab). Lets users explore the
catalogue independent of their own library, in three scrolling sections:
genres, releases, and curated collections.

## Architecture
- `browse_screen.dart`: the Browse tab — a single `ListView` of three sections:
  - **Genres**: a responsive grid of genre cards (`BrowseGenresBloc`). Keeps a
    group header because its body (the grid) carries no header of its own; the
    first-load placeholder is a shimmer grid (`SkeletonBox`), not a spinner.
  - **Releases**: `LazyDiscoveryGamesWidget` rows for `newReleases` + `comingSoon`
    (reuses the Home `DiscoveryGamesBloc` + discovery widgets). No group header —
    each row self-labels (matching Home), and the section collapses to nothing
    when both rows are empty.
  - **Collections**: `CollectionsWidget` (reuses the Home `CollectionsBloc`). No
    group header — the widget self-labels each collection and hides entirely when
    empty. Browse passes `maxCollections: CollectionsWidget.unbounded` to show
    every collection (Home keeps the tight default cap of 3).
- Pull-to-refresh reloads the **whole** hub: it re-dispatches
  `BrowseGenresLoadRequested`, `DiscoveryGamesLoadRequested` for both release
  rows, and `CollectionsLoadRequested`, then awaits all three streams settling
  (via `Future.wait`) before the indicator resolves.
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
- Releases rows: each row gets its **own** prefix so a game appearing in both
  (and both rows stay alive together) doesn't collide — `browse-new-releases-`
  for `newReleases`, `browse-coming-soon-` for `comingSoon`. Threaded into
  `LazyDiscoveryGamesWidget` → `DiscoveryGamesWidget` → `DiscoveryGameTile`.
- Collections rows: `browse-col-<collectionId>-` — the `CollectionsWidget`
  `heroTagPrefix` (`browse-`) is prepended to its per-collection `col-<id>-`
  namespace.

The prefix is forwarded to the destination `GameDetailsScreen` via the GoRouter
`extra` (`context.pushNamed(..., extra: heroTagPrefix)` in `DiscoveryGameTile`),
which rebuilds the destination cover Hero tag as `${heroTagPrefix}game-cover-<id>`
so it matches the exact source row the user tapped.

`DiscoveryGamesWidget`, `LazyDiscoveryGamesWidget`, and `CollectionsWidget` all
take an optional `heroTagPrefix` (default `''`, so the Home tab is unchanged).
