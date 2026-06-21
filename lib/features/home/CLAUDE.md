# Home Feature

## Overview
The home tab — a read-only discovery dashboard. It composes the games feature's
widgets into a scrollable feed: featured banners, anticipated games, discovery
rows (trending/new releases/coming soon), curated collections, and personalized
recommendations.

## Architecture
- `home_screen.dart`: the dashboard UI. A `StatelessWidget` that only lays out
  the section widgets.

`HomeScreen` has **no bloc of its own**. Every section is driven by a bloc from
the games feature (`AnticipatedGamesBloc`, `DiscoveryGamesBloc`,
`FeaturedBannersBloc`, `RecommendationsBloc`, `CollectionsBloc`), all provided
in `app_router.dart` via `MultiBlocProvider` on the home route. Do not add
providers or DI inside `HomeScreen`.

## Testing
- Widget test `HomeScreen` (section widgets render given their blocs).
