# Library Feature Documentation

## Overview

The Library feature allows users to track their game collection with status, scores, playtime, and favorites. It uses a caching strategy to minimize IGDB API costs.

## Architecture

This feature follows the established patterns documented in the root `CLAUDE.md`:

- **Repository Pattern**: `LibraryRepository` handles API communication
- **BLoC Pattern**: `LibraryBloc` manages state with optimistic updates
- **Router Registration**: BLoC provider and repository registration in `app_router.dart`

## Components

### Models (`library_entry_model.dart`)

Domain models for library entries:

- **`GameStatus`**: Enum for tracking status
  - `planned` - Want to play
  - `onHold` - Paused
  - `playing` - Currently playing
  - `finished` - Completed
  - `dropped` - Abandoned

  **Methods**:
  - `fromString(String)` - Parse from API (e.g., "on_hold" → `onHold`)
  - `toApiString()` - Convert to API format (e.g., `onHold` → "on_hold")
  - `displayName` - User-friendly name (e.g., "On Hold")

- **`CachedGame`**: Game data cached from IGDB
  - `id`: UUID from backend cache
  - `igdbId`: Original IGDB identifier
  - `name`: Game title
  - `coverUrl`: Cover image URL (optional)
  - `firstReleaseDate`: Release date (optional)
  - `lastSyncedAt`: When data was last refreshed

- **`CachedPlatform`**: Platform data cached from IGDB
  - `id`: UUID from backend cache
  - `igdbPlatformId`: Original IGDB identifier
  - `name`: Platform name
  - `abbreviation`: Short name (e.g., "PC", "PS5")
  - `logoUrl`: Platform logo URL (optional)

- **`LibraryEntry`**: User's game tracking entry
  - `id`: Entry UUID
  - `userId`: Owner's UUID
  - `game`: Associated `CachedGame`
  - `platform`: Optional `CachedPlatform`
  - `status`: Current `GameStatus`
  - `score`: Rating 0-100 (optional)
  - `playtimeMinutes`: Time played (optional)
  - `startDate`, `endDate`: Play period (optional)
  - `difficulty`: User-defined difficulty (optional)
  - `isFavorite`: Favorite flag
  - `notes`: User notes (optional)

  **Computed Properties**:
  - `playtimeFormatted`: Human-readable playtime (e.g., "20h 30m")

  **Methods**:
  - `copyWith()`: Create copy with modified fields

### Repository (`library_repository.dart`)

**Methods**:

1. `getLibrary(String userId, {bool? favoritesOnly, GameStatus? status})`
   - Fetches user's library from `/users/:userId/library`
   - Supports filtering by favorites and status
   - Returns `List<LibraryEntry>`

2. `addToLibrary({required int igdbId, required GameStatus status, ...})`
   - Adds game to library via `POST /library`
   - Accepts optional: platform, score, playtime, dates, difficulty, favorite, notes
   - Returns created `LibraryEntry`

3. `updateLibraryEntry(String entryId, {...})`
   - Updates entry via `PUT /library/:id`
   - All fields optional (partial update)
   - Returns updated `LibraryEntry`

4. `toggleFavorite(String entryId)`
   - Toggles favorite status via `POST /library/:id/favorite`
   - Returns updated `LibraryEntry`

5. `deleteLibraryEntry(String entryId)`
   - Removes entry via `DELETE /library/:id`

**Dependencies**: `IHttpClient` for HTTP communication

### BLoC (`bloc/library_bloc.dart`)

Manages library state with optimistic UI updates.

**Events**:

- `LibraryLoadRequested(userId)` - Load user's library
- `LibraryRefreshRequested` - Refresh current library
- `LibraryAddGameRequested(igdbId, status, ...)` - Add game to library
- `LibraryUpdateEntryRequested(entryId, ...)` - Update entry
- `LibraryToggleFavoriteRequested(entryId)` - Toggle favorite
- `LibraryDeleteEntryRequested(entryId)` - Remove entry
- `LibraryFilterToggled(showFavoritesOnly)` - Toggle favorites filter
- `LibraryStatusFilterChanged(status)` - Set status filter
- `LibraryClearError` - Clear error message

**State** (`LibraryState`):

```dart
LibraryState({
  status: LibraryStatus,          // initial, loading, success, failure
  entries: List<LibraryEntry>,    // All entries from server
  userId: String?,                // Current user
  errorMessage: String?,          // Error description
  showFavoritesOnly: bool,        // Favorites filter active
  statusFilter: GameStatus?,      // Status filter (null = all)
  isAddingGame: bool,             // Add operation in progress
})
```

**Computed Properties**:

- `filteredEntries` - Entries after applying active filters

**Optimistic Updates**:

Toggle favorite and delete operations update UI immediately, then revert on failure:

```dart
// Optimistic toggle
final updatedEntries = state.entries.map((e) =>
  e.id == entryId ? e.copyWith(isFavorite: !e.isFavorite) : e
).toList();
emit(state.copyWith(entries: updatedEntries));

// API call
try {
  await repository.toggleFavorite(entryId);
} catch (e) {
  // Revert on failure
  emit(state.copyWith(entries: originalEntries, errorMessage: e.toString()));
}
```

### Screen (`games_screen.dart`)

Displays the user's library with filtering controls.

**Features**:

- Filter chips: All Games, Favorites, Status filters
- Library entry cards with game cover, status, score, playtime
- Swipe-to-delete with undo snackbar
- Pull-to-refresh
- Empty states for no games/no matches
- Error handling with retry

**UI Components**:

- `_FilterChips` - Horizontal scrollable filter row
- `_LibraryEntryCard` - Individual entry display
- Favorite toggle via heart icon button

### Widget: Add to Library Bottom Sheet (`widgets/add_to_library_bottom_sheet.dart`)

Modal bottom sheet for adding or editing library entries. Used from Game Details screen.

**Usage**:

```dart
// Show the bottom sheet (static method)
AddToLibraryBottomSheet.show(
  context: context,
  gameId: game.igdbId,
  gameName: game.name,
  coverUrl: game.cover?.url,
  platforms: game.platforms,
  existingEntry: libraryEntry,  // Optional: for edit mode
);
```

**Features**:

- **Add Mode**: Create new library entry with game data from Game Details
- **Edit Mode**: Modify existing entry (pre-fills all fields)
- **Delete**: Available in edit mode with confirmation

**Form Fields**:

| Field      | Widget                    | Description                                           |
| ---------- | ------------------------- | ----------------------------------------------------- |
| Status     | `ChoiceChip` row          | Required: planned, playing, finished, onHold, dropped |
| Platform   | `DropdownButtonFormField` | Optional: from game's supported platforms             |
| Score      | `Slider`                  | Optional: 0-100 with live preview                     |
| Favorite   | Toggle icon button        | Integrated with score slider row                      |
| Playtime   | Hours + Minutes inputs    | Optional: InputFormatters for validation              |
| Start Date | `showDatePicker`          | Optional: when started playing                        |
| End Date   | `showDatePicker`          | Optional: when finished/dropped                       |
| Difficulty | `DropdownButtonFormField` | Optional: Easy, Normal, Hard, etc.                    |
| Notes      | `TextFormField`           | Optional: multiline notes (max 3 lines visible)       |

**BLoC Integration**:

Dispatches events to `LibraryBloc`:

- `LibraryAddGameRequested` - Add new entry
- `LibraryUpdateEntryRequested` - Update existing entry
- `LibraryDeleteEntryRequested` - Remove entry

**Listens to**:

- `LibraryStatus.success` - Shows snackbar, closes sheet
- `LibraryStatus.failure` - Shows error snackbar

**Design**:

- Rounded top corners (16px)
- Scrollable content for small screens
- Action buttons fixed at bottom (Cancel/Save)

## API Endpoints

| Method | Path                     | Description         |
| ------ | ------------------------ | ------------------- |
| POST   | `/library`               | Add game to library |
| GET    | `/users/:userId/library` | Get user's library  |
| GET    | `/library/:id`           | Get single entry    |
| PUT    | `/library/:id`           | Update entry        |
| DELETE | `/library/:id`           | Remove entry        |
| POST   | `/library/:id/favorite`  | Toggle favorite     |

## Error Codes

- `error.library.status.invalid` - Invalid status value
- `error.library.igdb_id.invalid` - Invalid IGDB game ID
- `error.library.entry.already_exists` - Duplicate entry
- `error.library.entry.not_found` - Entry not found
- `error.library.entry.unauthorized` - Not owner

## Testing

### Unit Tests

- `library_repository_test.dart` - Repository and model tests
- `library_bloc_test.dart` - BLoC event handling and state transitions

### Test Patterns

```dart
blocTest<LibraryBloc, LibraryState>(
  'emits [loading, success] when load succeeds',
  build: () {
    when(() => mockRepo.getLibrary(userId)).thenAnswer((_) async => entries);
    return LibraryBloc(libraryRepository: mockRepo);
  },
  act: (bloc) => bloc.add(LibraryLoadRequested(userId: userId)),
  expect: () => [
    predicate<LibraryState>((s) => s.status == LibraryStatus.loading),
    predicate<LibraryState>((s) => s.status == LibraryStatus.success),
  ],
);
```

## Data Freshness

Games and platforms are cached from IGDB. The backend refreshes stale data (24h+) automatically in the background when accessed. This is transparent to the Flutter app.
