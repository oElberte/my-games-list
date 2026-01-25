# Games Feature Documentation

## Overview

The Games feature provides integration with the IGDB (Internet Game Database) API to display anticipated game releases with countdown timers.

## Architecture

This feature follows the established patterns documented in the root `CLAUDE.md`:

- **Repository Pattern**: `GamesRepository` handles API communication
- **BLoC Pattern**: `AnticipatedGamesBloc` manages state and business logic
- **Router Registration**: All BLoC providers and repository registration are in `app_router.dart`

## Components

### Models (`anticipated_game_model.dart`)

Domain models for IGDB game data:

- **`GamePlatform`**: Represents gaming platforms (PlayStation, Xbox, PC, etc.)
  - `id`: Platform identifier
  - `name`: Platform display name

- **`AnticipatedGame`**: Represents a game with release information
  - `id`: Game identifier
  - `name`: Game title
  - `coverUrl`: Cover image URL
  - `hypes`: Number of hype votes on IGDB
  - `firstReleaseDate`: Release date as DateTime
  - `platforms`: List of supported platforms

  **Computed Properties**:
  - `timeUntilRelease`: Duration until release
  - `isReleased`: Boolean indicating if already released
  - `countdownText`: Formatted countdown string (e.g., "45d 12h 30m")
  - `platformNames`: Comma-separated platform names

- **`AnticipatedGamesResponse`**: API response wrapper

### Repository (`games_repository.dart`)

**Method**: `getAnticipatedGames()`

- Fetches most anticipated games from backend endpoint `/games/anticipated`
- Parses response into `AnticipatedGamesResponse`
- Throws exceptions with user-friendly messages on errors

**Dependencies**: `IHttpClient` for HTTP communication

### BLoC (`bloc/`)

**`AnticipatedGamesBloc`**

Manages the state of anticipated games with automatic countdown updates.

**Events**:

- `AnticipatedGamesLoadRequested`: Initial load of games
- `AnticipatedGamesRefreshRequested`: Refresh games (e.g., pull-to-refresh)
- `AnticipatedGamesCountdownTick`: Internal event for countdown updates

**State**: `AnticipatedGamesState`

- `status`: Enum (initial, loading, success, failure)
- `games`: List of anticipated games
- `errorMessage`: Error message for failure state
- `lastUpdated`: Timestamp of last successful update
- `countdownTick`: Counter to force UI rebuilds on timer tick

**Business Logic**:

- **Countdown Timer**: Updates every 1 minute to refresh countdown displays
- **Duplicate Prevention**: Ignores load requests when already loading
- **Error Handling**: Keeps existing games on refresh failure
- **Lifecycle**: Cancels timer on bloc disposal

### UI Widgets (`widgets/`)

**`AnticipatedGamesCarousel`**

Carousel display of anticipated games with modern design.

**Features**:

- Auto-play with 5-second interval
- 75% viewport fraction for peek effect
- Center enlargement for focus
- Loading, error, and empty states

**`_GameCard`**

- Stack-based layout with cover image
- Gradient overlay for text readability
- Rounded corners (16px radius)
- Elevation shadow (12px with 6px offset)
- Countdown badge overlay (top-right)
- Game info section (bottom)

**`_CountdownBadge`**

- Semi-transparent background (60% opacity)
- Timer icon with countdown text
- Positioned at top-right corner
- 8px padding, 8px border radius

**Design System**:

- Colors: Gradient overlays, theme-based text
- Spacing: 16px bottom margin for shadow clearance
- Typography: Bold titles, regular metadata
- Icons: `local_fire_department` for "Most Anticipated" header

## Integration Points

### Backend API

**Endpoint**: `GET /api/v1/games/anticipated`

- Returns anticipated games from IGDB
- Requires valid IGDB OAuth token (handled by backend middleware)
- Response includes game details, platforms, and release dates

### Home Screen Integration

The games carousel is integrated into `HomeScreen` through the router configuration in `app_router.dart`:

```dart
// Home Route with BLoC providers
GoRoute(
  path: homePath,
  name: homeName,
  builder: (context, state) {
    // Register games repository lazily
    _ensureGamesRepositoryRegistered();

    // Provide both HomeBloc and AnticipatedGamesBloc
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<HomeBloc>()..add(const HomeInitialized()),
        ),
        BlocProvider(
          create: (_) => AnticipatedGamesBloc(
            gamesRepository: sl<GamesRepository>(),
          )..add(const AnticipatedGamesLoadRequested()),
        ),
      ],
      child: const HomeScreen(),
    );
  },
),
```

**Important**: Do NOT add BLoC providers or repository registration in `HomeScreen` itself. All dependency injection happens in the router.

## Testing

### Repository Tests (`games_repository_test.dart`)

- Successful response parsing
- Empty list handling
- API error handling
- Model serialization (fromJson/toJson)
- Countdown text formatting
- Platform names joining

### BLoC Tests (`bloc/anticipated_games_bloc_test.dart`)

- Load success/failure scenarios
- Duplicate loading prevention
- Refresh with existing games
- Refresh failure keeps games
- Countdown tick increments
- Timer lifecycle (start/stop)
- State getters (isLoading, hasGames)
- Event equality

**Test Coverage**: 24 tests total

## Future Enhancements

Potential improvements for the games feature:

- Pull-to-refresh on home screen
- Game detail screen on carousel tap
- Search and filter functionality
- Favorites/wishlist support
- Push notifications for release dates
- Caching layer for IGDB responses
