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

**`DiscoveryGamesBloc`**

Manages discovery games (trending, indie, upcoming) with pagination and view mode toggle.

**Events**:

- `DiscoveryGamesLoadRequested(DiscoveryType type)`: Initial load of discovery games
- `DiscoveryGamesLoadMore`: Load next page of results (infinite scroll)
- `DiscoveryGamesViewModeToggled`: Toggle between grid and list view
- `DiscoveryGamesRefreshRequested`: Refresh games (pull-to-refresh)

**State Architecture**:

The state uses a per-type architecture to allow multiple discovery widgets to share the same BLoC without overwriting each other's data:

- **`DiscoveryTypeState`**: State for a single discovery type
  - `status`: Enum (initial, loading, success, failure, loadingMore)
  - `games`: List of games for this type
  - `errorMessage`: Error message for failure state
  - `hasMore`: Boolean indicating more results available
  - `currentOffset`: Current pagination offset
  - `offsetLimitReached`: Boolean for 10k offset limit

- **`DiscoveryGamesState`**: Main state container
  - `stateByType`: `Map<DiscoveryType, DiscoveryTypeState>` - Separate state per discovery type
  - `viewMode`: Current view mode (grid, list) - shared across types
  - `activeDiscoveryType`: The discovery type that `DiscoveryGamesLoadMore` and `DiscoveryGamesRefreshRequested` operate on (set on load)
  - `getStateForType(DiscoveryType)`: Get the state for a specific discovery type
  - `updateTypeState(type, update)`: Update state for a specific type

**Key Design Decisions**:

- Each discovery type maintains independent state (trending games won't overwrite indie games)
- Widgets use `buildWhen` to only rebuild when their specific type's state changes
- View mode is shared across all types
- `activeDiscoveryType` is set when `DiscoveryGamesLoadRequested` is received

**Business Logic**:

- **Discovery Types**: trending (popularity), indie (genre), upcoming (unreleased with hype)
- **Pagination**: 20 results per page, offset-based
- **View Toggle**: Grid (3 columns) or List view persistence
- **Cache**: Backend caches results for 1 hour per type/offset/limit
- **Error Handling**: Keeps existing games on load more failure
- **Offset Limit**: IGDB API limits offset to 10,000 results

### Discovery Models (`discovery_game_model.dart`)

Domain models for discovery games functionality:

- **`DiscoveryType`**: Enum for discovery categories
  - `trending`: Games sorted by popularity
  - `indie`: Indie genre games sorted by rating
  - `upcoming`: Unreleased games sorted by hype
  - **Properties**: `queryParam`, `displayName`
  - **Methods**:
    - `localizedName(BuildContext context)`: Returns the localized display name for the discovery type (e.g., "Trending Now", "Indie Gems", "Upcoming Games"). Uses `context.l10n` for i18n support.
    - `fromQueryParam(String param)`: Creates a DiscoveryType from a query parameter string

- **`DiscoveryGame`**: Represents a game from discovery results
  - `id`: Game identifier
  - `name`: Game title
  - `coverUrl`: Cover image URL (optional)
  - `totalRating`: IGDB rating 0-100 (optional)
  - **Computed Properties**:
    - `ratingPercentage`: Formatted rating (e.g., "93%")
    - `hasRating`: Boolean for rating availability

- **`DiscoveryGamesResponse`**: API response wrapper with pagination
  - `games`: List of discovery results
  - `type`: Discovery type string
  - `totalCount`: Number of results in response
  - `hasMore`: Boolean indicating more results
  - `offset`: Current offset value
  - `limit`: Page size

### Discovery Widgets

**`DiscoveryGamesWidget`** (`widgets/discovery_games_widget.dart`)

Horizontal scrolling widget for home screen. Loads data immediately when mounted.

**Features**:

- Header with icon, title (localized based on discovery type), and "See All" button
- Horizontal ListView of game tiles
- Loading, error, and empty states
- Navigates to full discovery screen on "See All" tap
- Uses `discoveryType.localizedName(context)` for i18n titles

**`LazyDiscoveryGamesWidget`** (`widgets/discovery_games_widget.dart`)

Lazy-loading wrapper for DiscoveryGamesWidget. Only triggers data loading when the widget becomes visible in the viewport.

**Properties**:

- `discoveryType`: The type of discovery games to load
- `icon`: Optional custom icon override
- `visibilityThreshold`: Fraction of widget that must be visible to trigger loading (default: 0.1 = 10%)

**Features**:

- Uses `VisibilityDetector` package to detect when widget enters viewport
- Prevents duplicate load requests with `_hasTriggeredLoad` flag
- Calls `setState()` when visibility is detected to trigger widget rebuild
- Uses `buildWhen` to only rebuild when the specific discovery type's state changes
- Uses `state.getStateForType(discoveryType)` to access type-specific data
- Shows loading placeholder until visibility threshold is met
- Ideal for sections below the fold (e.g., Indie Gems on home screen)
- Same loading/error/success states as `DiscoveryGamesWidget`

**Usage on Home Screen**:

The home screen uses both widgets with a shared BLoC:

- `DiscoveryGamesWidget(discoveryType: DiscoveryType.trending)` - Loads immediately (visible on mount)
- `LazyDiscoveryGamesWidget(discoveryType: DiscoveryType.indie)` - Lazy loaded when scrolled into view

Each widget maintains independent data via the per-type state architecture.

**`DiscoveryGameTile`** (`widgets/discovery_game_tile.dart`)

Grid tile widget for discovery games.

**Layout**:

- Cover image with gradient overlay
- Rating badge (color-coded: green > yellow > red)
- Game name at bottom
- Rounded corners with shadow

**Features**:

- Cached network images
- Placeholder icon for missing covers
- Material 3 design
- Navigates to game details on tap

**`DiscoveryGameListTile`** (`widgets/discovery_game_tile.dart`)

List tile variant for discovery games.

**Layout**:

- Horizontal card (cover left, info right)
- Rating badge next to title
- Chevron arrow on right

**`DiscoveryGamesScreen`** (`discovery_games_screen.dart`)

Full screen for browsing discovery games.

**Features**:

- AppBar with title and grid/list toggle button
- Infinite scroll pagination (triggers at 90% scroll)
- Pull-to-refresh
- GridView (3 columns) or ListView based on view mode
- Loading, error, and empty states
- Offset limit reached message

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

**Navigation**:

- Tapping card navigates to `GameDetailsScreen` using `context.pushNamed('gameDetails', pathParameters: {'id': game.id.toString()})`
- Cover image wrapped in `Hero` widget with tag `'game-cover-${game.id}'` for smooth transition animation

### Game Details (`game_details_screen.dart`)

Full-screen game details view with collapsible header and library integration.

**Layout**:

- `CustomScrollView` with `SliverAppBar` (collapsible header)
- Hero-animated cover image in app bar
- Sections: Info, Tags, Description, Screenshots, Videos, Similar Games, Where to Buy
- `FloatingActionButton.extended` for library actions

**Library Integration**:

Wrapped in `BlocBuilder<LibraryBloc, LibraryState>` to access library data.

**App Bar Actions**:

- **Favorite Button**: Heart icon (filled when favorite), toggles `LibraryToggleFavoriteRequested`
  - Only shown when game is in library
- **Share Button**: Share icon, opens native share sheet or copies to clipboard
  - Share URL format: `{Env.webBaseUrl}/games/{igdbId}`
  - Uses `share_plus` package with clipboard fallback

**Floating Action Button**:

- Extended FAB at bottom-right, positioned above content
- Shows current status (e.g., "Playing") with checkmark if in library
- Shows "Add" with plus icon if not in library
- Tapping opens `AddToLibraryBottomSheet`

**Helper Methods**:

```dart
// Find library entry by IGDB ID
LibraryEntry? _findLibraryEntry(LibraryState state) {
  if (state.status != LibraryStatus.success) return null;
  return state.entries.where((e) => e.game.igdbId == gameId).firstOrNull;
}

// Share game with fallback
Future<void> _shareGame(BuildContext context, GameDetail game) async {
  final url = '${Env.webBaseUrl}/games/${game.id}';
  final text = '${context.l10n.checkOutThisGame} ${game.name}: $url';
  await Share.share(text);
}

// Toggle favorite status
void _toggleFavorite(BuildContext context, String entryId) {
  context.read<LibraryBloc>().add(LibraryToggleFavoriteRequested(entryId: entryId));
}

// Open library bottom sheet
void _openLibrarySheet(BuildContext context, GameDetail game, LibraryEntry? entry) {
  AddToLibraryBottomSheet.show(
    context: context,
    gameId: game.id,
    gameName: game.name,
    coverUrl: game.cover?.url,
    platforms: game.platforms,
    existingEntry: entry,
  );
}
```

**Visual Design**:

- Gradient overlay on cover fades to `scaffoldBackgroundColor` (3 stops: 0.0, 0.5, 1.0)
- Extra bottom padding (80px) to accommodate FAB
- FAB uses primary color for "in library" state, surface color for "add" state

**Sections**:

**`_InfoRow`**:

- Hero-animated cover thumbnail (90x120)
- Developer name
- 5-star rating display using `RatingBarIndicator`
- Rating score converted from 0-100 to 0-5 scale

**`_TagsSection`**:

- Genre chips (primary color)
- Platform chips (secondary color)

**`_DescriptionSection`**:

- Expandable text with "Read more"/"Read less" toggle
- Shows first 200 characters when collapsed

**`_ScreenshotsSection`**:

- Horizontal scroll of screenshot thumbnails
- Tapping opens full-screen image view

**`_VideosSection`**:

- Horizontal scroll of video thumbnail cards
- Tapping opens in-app YouTube player (`VideoPlayerScreen`)

**`_SimilarGamesSection`**:

- Horizontal scroll of similar game cards
- Tapping navigates to that game's details

**`_WebsitesSection`**:

- External links (Steam, Official site, Discord, etc.)
- Uses `url_launcher` to open in browser
- Icons and names from `website_category.dart` utility

**`VideoPlayerScreen`** (`widgets/video_player_screen.dart`):

- Full-screen in-app YouTube player
- Uses `youtube_player_iframe` package
- Extracts video ID from YouTube URL
- Supports landscape mode, auto-play

**`VideoThumbnailCard`** (`widgets/video_thumbnail_card.dart`):

- Displays YouTube video thumbnail
- Video name overlay at bottom
- Play button icon overlay
- Tappable to open `VideoPlayerScreen`

### Game Details BLoC (`bloc/game_details_*.dart`)

**`GameDetailsBloc`**

Manages game details loading state.

**Events**:

- `GameDetailsLoadRequested`: Fetch game details by ID

**State**: `GameDetailsState`

- `status`: Enum (initial, loading, success, failure)
- `gameDetail`: The loaded `GameDetail` model
- `errorMessage`: Error message for failure state

**Business Logic**:

- Calls `GamesRepository.getGameDetails(id)`
- Handles errors with user-friendly messages

### Game Details Model (`game_detail_model.dart`)

Domain models for game details:

- **`GameDetail`**: Complete game information
  - `id`, `name`, `summary`, `storyline`
  - `rating`: 0-100 scale from IGDB
  - `fiveStarRating`: Computed 0-5 scale (rating / 20)
  - `cover`: Cover image info
  - `genres`, `platforms`: Lists
  - `involvedCompanies`: Developers/publishers
  - `developer`: First developer name (computed)
  - `screenshots`, `videos`, `websites`
  - `similarGames`: Related games

- **`Genre`**, **`Platform`**, **`Company`**, **`InvolvedCompany`**
- **`Screenshot`**: Screenshot URL
- **`Video`**: YouTube video ID and name
- **`Website`**: External link with category
- **`SimilarGame`**: Basic info for related games

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

3. `GET /api/v1/games/:id`
   - Returns detailed information for a specific game
   - Response includes: cover, genres, platforms, developers, screenshots, videos, websites, similar games
   - Video URLs converted to YouTube links
   - Image URLs transformed to high-resolution versions
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

    // Provide the home dashboard blocs (AnticipatedGamesBloc,
    // DiscoveryGamesBloc, FeaturedBannersBloc, RecommendationsBloc,
    // CollectionsBloc)
    return MultiBlocProvider(
      providers: [
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

### Game Details Screen Integration

Route configuration in `app_router.dart`:

```dart
// Game Details Route
GoRoute(
  path: gameDetailsPath, // '/games/:id'
  name: gameDetailsName,
  builder: (context, state) {
    _ensureGamesRepositoryRegistered();
    final gameId = int.parse(state.pathParameters['id']!);
    return BlocProvider(
      create: (_) => GameDetailsBloc(gamesRepository: sl<GamesRepository>())
        ..add(GameDetailsLoadRequested(gameId)),
      child: GameDetailsScreen(gameId: gameId),
    );
  },
),
```

**Navigation**:

- From `AnticipatedGamesCarousel`: Tap on game card
- From `GameSearchCard`: Tap on search result
- From `GameDetailsScreen`: Tap on similar game
- Route: `/games/:id`
- Named route: `AppRouter.gameDetailsName`

**Hero Animation**:

- Cover images use `Hero` widget with tag `'game-cover-${game.id}'`
- Provides smooth transition animation between list and detail views

### Video Player Integration

Route configuration in `app_router.dart`:

```dart
// Video Player Route
GoRoute(
  path: videoPlayerPath, // '/video/:videoId'
  name: videoPlayerName,
  builder: (context, state) {
    final videoId = state.pathParameters['videoId']!;
    final videoName = state.uri.queryParameters['name'] ?? '';
    return VideoPlayerScreen(videoId: videoId, videoName: videoName);
  },
),
```

**Navigation**:

- From `GameDetailsScreen`: Tap on video thumbnail
- Uses `youtube_player_iframe` for in-app playback
- Supports full-screen landscape mode

## Testing

### Repository Tests (`games_repository_test.dart`)

**Anticipated Games**:

- Successful response parsing
- Empty list handling
- API error handling
- Model serialization (fromJson/toJson)
- Countdown text formatting
- Platform names joining

**Search Games**:

- Successful search response parsing
- Pagination metadata validation
- Empty results handling
- Offset limit handling
- Query validation
- API error scenarios

**Game Details**:

- Successful details response parsing
- Invalid game ID handling
- Game not found handling
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

**`game_search_bloc_test.dart`**:

- Query changed emits loading then success
- Empty query clears state
- Load more appends games
- Offset limit reached stops loading
- Debouncing prevents rapid requests
- Error handling preserves existing games
- State computed properties
- Event equality

**`game_details_bloc_test.dart`**:

- Load success emits loaded state
- Load failure emits error state
- Invalid game ID handling
- State equality

### Model Tests

**`game_detail_model_test.dart`**:

- JSON parsing for all nested types
- `fiveStarRating` computation (0-100 to 0-5 scale)
- `developer` getter returns first developer name
- Handles null/missing fields gracefully
- Equatable equality

### Widget Tests

**`widgets/anticipated_games_carousel_test.dart`**:

- Displays carousel with games
- Shows game names and countdown badges
- Has Hero widgets for cover images
- Displays page indicator dots
- Allows swiping between games
- GestureDetector for tapping
- Empty state handling
- Games without cover URL

**`widgets/game_search_card_test.dart`**:

- Displays game name, genres, platforms, release date
- Has Hero widget with correct tag
- InkWell tappable with rounded card
- Icons for category, devices, calendar
- Handles missing cover, genres, platforms, date

**Current Test Coverage**: 50+ tests across all game feature components

## Current Implementation Status

### ✅ Implemented Features

**Anticipated Games**:

- Carousel display with countdown timers
- Auto-refresh every minute
- IGDB integration via backend API
- Pull-to-refresh support
- Loading, error, and empty states
- Navigation to game details on tap
- Hero animation for cover images

**Game Search**:

- Full-text search across IGDB database
- Debounced search input (500ms)
- Infinite scroll pagination
- Offset limit handling (10,000 max)
- Search result cards with cover images
- Accessible via search icon on home screen
- Navigation to game details on tap
- Hero animation for cover images

**Game Details**:

- Full-screen detail view with collapsible header
- Hero animation for smooth transitions
- 5-star rating display (converted from 0-100)
- Genre and platform chips
- Expandable description
- Screenshot gallery with full-screen view
- In-app YouTube video player
- Similar games carousel with navigation
- External links (Steam, Discord, etc.) via url_launcher
- Developer/publisher information

### 🚧 In Progress / Next Steps

**Search Enhancements**:

- Advanced filters (genre, platform, year, rating)
- Sort options (name, rating, release date)
- Search history and suggestions
- Caching layer for search results

**Game Details Enhancements**:

- Add to user game lists
- Mark as played/completed/wishlist
- User ratings and reviews
- Social sharing

**Anticipated Games**:

- Pull-to-refresh on home screen
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

**Phase 3: Game Details** ✅ **COMPLETED**

- Detailed game information screen
- Screenshots, videos, and similar games
- External links (Steam, Discord, official sites)
- 5-star rating display
- In-app YouTube video player
- Hero animation transitions

**Phase 4: User Lists**

- Custom game lists
- Wishlist functionality
- Mark as played/completed
- Personalized recommendations
- Add to list from game details

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
