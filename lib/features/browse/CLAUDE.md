# Browse Feature

## Overview
The public discovery hub (the "Browse" / "Explorar" tab). Lets users explore the
catalogue by genre, independent of their own library.

## Architecture
- `browse_screen.dart`: the Browse tab — a responsive grid of genre cards.
- `browse_genre_games_screen.dart`: a pushed screen with top-rated games for one
  genre (route `/browse/genres/:genreId?name=`).
- `bloc/browse_genres_*`: loads the genre list (`GamesRepository.getGenres`).
- `bloc/browse_genre_games_*`: loads games for a genre
  (`GamesRepository.getGamesByGenre` → `/games/discovery?type=by_genre&genre_id=`).

Blocs are provided in `app_router.dart` (the `/browse` shell branch and the
`/browse/genres/:genreId` route). The `Genre` model is reused from
`features/games/game_detail_model.dart`.

## Hero tags
The per-genre grid namespaces cover Heroes with `browse-genre-<id>-` so they
can't collide with the Home tab's rows — both branches live in the same
`StatefulShellRoute.indexedStack` and are kept alive simultaneously.

## Follow-ups
Releases and curated-collections rows on the Browse tab are intentionally
deferred: reusing the Home row widgets in-shell first needs a Hero-namespace
prefix threaded through `DiscoveryGamesWidget` / `LazyDiscoveryGamesWidget` /
`CollectionsWidget` to avoid cross-tab Hero collisions.
