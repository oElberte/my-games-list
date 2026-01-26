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

**Methods**:

1. `getAnticipatedGames()`
   - Fetches most anticipated games from backend endpoint `/games/anticipated`
   - Parses response into `AnticipatedGamesResponse`
   - Throws exceptions with user-friendly messages on errors

2. `searchGames(String query, {int limit = 20, int offset = 0})`
   - Searches IGDB database for games matching the query
   - Backend endpoint: `POST /games/search`
   - Returns `SearchGamesResponse` with pagination metadata
   - Supports offset-based pagination (max offset: 10,000)
   - Throws exceptions with user-friendly messages on errors

**Dependencies**: `IHttpClient` for HTTP communication

### Search Models (`domain/search_game_model.dart`)

Domain models for game search functionality:

- **`GameGenre`**: Represents a game genre
  - `id`: Genre identifier
  - `name`: Genre name

- **`GamePlatform`**: Represents a gaming platform
  - `id`: Platform identifier
  - `name`: Platform name

- **`SearchGame`**: Represents a game from search results
  - `id`: Game identifier
  - `name`: Game title
  - `coverUrl`: Cover image URL (optional)
  - `firstReleaseDate`: Release date as DateTime (optional)
  - `genres`: List of game genres
  - `platforms`: List of supported platforms

- **`SearchGamesResponse`**: API response wrapper with pagination
  - `games`: List of search results
  - `totalCount`: Number of results in current response
  - `hasMore`: Boolean indicating more results available
  - `offset`: Current offset value
  - `limit`: Page size

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

**`GameSearchBloc`**

Manages game search with debouncing, infinite scroll pagination, and offset limit handling.

**Events**:

- `GameSearchQueryChanged`: Triggered when search query changes (debounced 500ms)
- `GameSearchLoadMore`: Load next page of results (infinite scroll)
- `GameSearchClear`: Clear search results and reset state

**State**: `GameSearchState`

- `status`: Enum (initial, loading, success, failure, loadingMore)
- `games`: List of search results
- `query`: Current search query
- `errorMessage`: Error message for failure state
- `hasMore`: Boolean indicating more results available
- `currentOffset`: Current pagination offset
- `offsetLimitReached`: Boolean for 10k offset limit

**Computed Properties**:
- `isLoading`: Loading initial results
- `isLoadingMore`: Loading next page
- `hasGames`: Has search results
- `isEmpty`: No results for query
- `canLoadMore`: Can fetch next page

**Business Logic**:

- **Debouncing**: 500ms delay to prevent excessive API calls during typing
- **Infinite Scroll**: Auto-loads more when user scrolls to 90% of list
- **Offset Limit**: IGDB API limits offset to 10,000 results
- **Pagination**: 20 results per page
- **State Management**: Preserves existing results when loading more
- **Error Handling**: Keeps existing games on load more failure
- **Lifecycle**: Cancels debounce timer on bloc disposal

### UI Components

**`GameSearchScreen`** (`game_search_screen.dart`)

Main search screen with infinite scroll and state handling.

**Features**:

- Search bar with clear button
- Debounced query input (500ms)
- Infinite scroll pagination (triggers at 90% scroll)
- Initial, loading, success, failure, and empty states
- Offset limit reached message
- Material 3 design

**State Screens**:
- `_InitialState`: "Search for your favorite games" prompt
- `_LoadingState`: Circular progress indicator
- `_ErrorState`: Error icon and message
- `_EmptyState`: "No results found" message
- `_LoadingMoreIndicator`: Bottom loader during pagination
- `_OffsetLimitReachedMessage`: Max results warning

**`GameSearchCard`** (`widgets/game_search_card.dart`)

Search result card with game information.

**Layout**:
- Horizontal card (cover left, info right)
- 90x120 cover image with rounded corners
- Game title (bold, max 2 lines)
- Genres (max 2, with category icon)
- Platforms (max 2, with devices icon)
- Release date (formatted with calendar icon)

**Features**:
- Cached network images for covers
- Placeholder for missing covers
- Material 3 card design (16px radius, 4px elevation)
- InkWell ripple effect
- TODO: Navigate to game detail screen on tap

**Design System**:
- Spacing: 8px horizontal, 6px vertical margin
- Typography: titleLarge for name, bodyMedium for metadata
- Icons: 16px size, grey color
- Colors: Grey text for metadata, dark grey for placeholders

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

**Endpoints**:

1. `GET /api/v1/games/anticipated`
   - Returns anticipated games from IGDB
   - Requires valid IGDB OAuth token (handled by backend middleware)
   - Response includes game details, platforms, and release dates

2. `POST /api/v1/games/search`
   - Searches IGDB database for games matching query
   - Request body: `{"query": "string", "limit": 1-50, "offset": 0-10000}`
   - Returns paginated search results with metadata
   - Offset limit: 10,000 (IGDB constraint)
   - Requires valid IGDB OAuth token (handled by backend middleware)

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

### Search Screen Integration

The search screen is accessible from the home screen via a search icon in the AppBar. Route configuration in `app_router.dart`:

```dart
// Search Route (outside bottom navigation)
GoRoute(
  path: searchPath,
  name: searchName,
  builder: (context, state) {
    // Register games repository lazily
    _ensureGamesRepositoryRegistered();

    // Provide GameSearchBloc (auto-disposed by BlocProvider)
    return BlocProvider(
      create: (_) => GameSearchBloc(gamesRepository: sl<GamesRepository>()),
      child: const GameSearchScreen(),
    );
  },
),
```

**Navigation**:
- From `HomeScreen`: Search icon in AppBar (top-right)
- Route: `/search` (outside bottom navigation shell)
- Named route: `AppRouter.searchName`

**User Flow**:
1. User taps search icon on home screen
2. Navigates to search screen
3. Types query (debounced 500ms)
4. Views results with infinite scroll
5. Taps back to return to home

## Testing

### Repository Tests (`games_repository_test.dart`)

**Anticipated Games**:
- Successful response parsing
- Empty list handling
- API error handling
- Model serialization (fromJson/toJson)
- Countdown text formatting
- Platform names joining

**Search Games** (To be implemented):
- Successful search response parsing
- Pagination metadata validation
- Empty results handling
- Offset limit handling
- Query validation
- API error scenarios

### BLoC Tests

**`anticipated_games_bloc_test.dart`**:
- Load success/failure scenarios
- Duplicate loading prevention
- Refresh with existing games
- Refresh failure keeps games
- Countdown tick increments
- Timer lifecycle (start/stop)
- State getters (isLoading, hasGames)
- Event equality

**`game_search_bloc_test.dart`** (To be implemented):
- Query changed emits loading then success
- Empty query clears state
- Load more appends games
- Offset limit reached stops loading
- Debouncing prevents rapid requests
- Error handling preserves existing games
- State computed properties
- Event equality

### UI Tests (To be implemented)

**`game_search_screen_test.dart`**:
- Initial state displays search prompt
- Loading state shows spinner
- Results display cards
- Scroll triggers load more
- Empty state shows message
- Error state shows error
- Clear button resets state

**`widgets/game_search_card_test.dart`**:
- Renders game information correctly
- Displays cover image or placeholder
- Shows genres, platforms, release date
- Handles missing data gracefully
- Tap triggers navigation (when implemented)

**Current Test Coverage**: 24 tests (anticipated games only)

## Current Implementation Status

### ✅ Implemented Features

**Anticipated Games**:
- Carousel display with countdown timers
- Auto-refresh every minute
- IGDB integration via backend API
- Pull-to-refresh support
- Loading, error, and empty states

**Game Search**:
- Full-text search across IGDB database
- Debounced search input (500ms)
- Infinite scroll pagination
- Offset limit handling (10,000 max)
- Search result cards with cover images
- Accessible via search icon on home screen

### 🚧 In Progress / Next Steps

**Search Enhancements**:
- Game detail screen navigation from search results
- Advanced filters (genre, platform, year, rating)
- Sort options (name, rating, release date)
- Search history and suggestions
- Caching layer for search results

**Anticipated Games**:
- Pull-to-refresh on home screen
- Game detail screen on carousel tap
- Push notifications for release dates
- Caching layer for IGDB responses

### 📋 Games Browse Screen (Placeholder - Not Yet Implemented)

**Status:** Currently displays "Coming Soon" placeholder

The Games screen (`games_screen.dart`) serves as one of the three main tabs in the bottom navigation bar and is a **placeholder** for future games browsing functionality.

**Current State:**
- Simple stateless widget
- Centered "Coming Soon" message
- Sports esports icon and description
- No BLoC or data layer yet

**Future Implementation Plan:**

**Phase 1: Popular/Trending Games**
- Leverage existing `GamesRepository`
- Create `GamesBrowseBloc` for state management
- Grid/list view of popular games
- Pull-to-refresh support

**Phase 2: Browse with Filters**
- Filter by genre, platform, release year
- Sort by popularity, rating, release date
- Reuse search infrastructure

**Phase 3: Game Details**
- Detailed game information screen
- Screenshots, videos, and similar games
- Add to user lists functionality
- Social sharing features

**Phase 4: User Lists**
- Custom game lists
- Wishlist functionality
- Mark as played/completed
- Personalized recommendations

**Reuse Opportunity:**
The Games browse screen can leverage the existing `GamesRepository`, search models, and search card widgets already implemented.

**Related Files:**
- `lib/features/games/games_screen.dart` - Placeholder UI
- `lib/features/games/games_repository.dart` - API client (can be reused)
- `lib/features/games/widgets/game_search_card.dart` - Can be reused for browse
- Bottom navigation integration in `app_router.dart`

**Test Coverage:**
- Placeholder screen tests in `test/features/games/games_screen_test.dart`
- Tests verify "Coming Soon" UI rendering
- Future: Add BLoC and widget tests when implemented
