# Core Module Documentation

## Overview

This directory contains the foundational building blocks of the application that are shared across multiple features. It must **NOT** contain any feature-specific business logic.

## Scope

- **Shared Utilities**: Helper functions, extensions, and constants.
- **Dependency Injection**: Service locator setup (e.g., `init_dependencies.dart` or similar).
- **Network Layer**: Generic HTTP clients (`IHttpClient`), interceptors, and error handling.
- **Storage Layer**: Local storage abstractions and implementations.
- **Common Widgets**: Reusable UI components (Buttons, Inputs, Loaders) used by multiple features.
- **Routing**: Global application router configuration.

## Architecture Principles

1.  **No Feature Dependencies**: Core components cannot depend on `features/`.
2.  **High Reusability**: Components here should be generic enough for any part of the app.
3.  **Stability**: Changes here affect the entire app, so changes should be backwards compatible where possible.

## Patterns

### Error Handling

See `lib/core/domain/models/api_error.dart` for the standardized error format used by the entire app.

### API Client

See `lib/core/data/network/` for the `IHttpClient` interface and `DioHttpClient` implementation.

## Navigation Architecture

### Router Configuration (`utils/app_router.dart`)

The app uses **GoRouter** for declarative routing with integrated authentication guards and state preservation.

**Key Patterns:**

1. **Modular Dependency Injection in Router**
   - All BLoC providers are registered in route builders, NOT in screen widgets
   - Repositories registered lazily as singletons when routes accessed
   - BLoCs auto-disposed when routes popped
2. **StatefulShellRoute for Bottom Navigation**
   - Uses `StatefulShellRoute.indexedStack` for tab persistence
   - Each tab (branch) maintains its own navigation state
   - Scroll positions and form data preserved when switching tabs
3. **Authentication-Aware Redirects**
   - `refreshListenable` monitors `AuthBloc` state stream
   - Automatic redirects based on auth status
   - Protected routes redirect to signin when unauthenticated

**Route Structure:**

```dart
GoRouter(
  initialLocation: '/splash',  // Splash screen checks auth
  refreshListenable: GoRouterRefreshStream(AuthBloc),
  redirect: (context, state) {
    // Allow splash to run first
    // Then redirect based on auth state
  },
  routes: [
    // Splash Route (no guards)
    GoRoute('/splash'),

    // Auth Routes
    GoRoute('/signin'),
    GoRoute('/signup'),

    // Bottom Navigation Shell (authenticated only)
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => BottomNavBar(shell),
      branches: [
        StatefulShellBranch([GoRoute('/home')]),
        StatefulShellBranch([GoRoute('/games')]),
        StatefulShellBranch([GoRoute('/profile')]),
      ],
    ),

    // Settings (outside shell, authenticated only)
    GoRoute('/settings'),
  ],
);
```

### Bottom Navigation Bar (`widgets/bottom_nav_bar.dart`)

**Material 3 NavigationBar** implementation with three tabs.

**Features:**

- Icons: Home, Games (sports_esports), Profile (person)
- Animated transitions (400ms duration)
- Always-visible labels
- State preservation via StatefulNavigationShell

**Tab Navigation:**

- Tapping current tab resets to initial location
- Switching tabs preserves scroll position and state
- Each tab has independent navigation stack

**Design:**

- Material 3 design tokens
- Theme-aware colors
- Outlined icons when unselected, filled when selected
- Smooth scale/fade animations

### Navigation Patterns

**DO:**

- ✅ Use `context.go('/path')` for navigation
- ✅ Use `context.goNamed('routeName')` for named routes
- ✅ Register BLoCs in route builders (app_router.dart)
- ✅ Use StatefulShellRoute for persistent bottom nav

**DON'T:**

- ❌ Use Navigator.push() directly (breaks GoRouter state)
- ❌ Register BLoCs in screen widgets
- ❌ Create multiple BLoC instances for same screen
- ❌ Nest StatefulShellRoutes

### Route Guards

**Splash Screen:**

- No guards, runs before auth check
- Dispatches `AuthStateLoaded` event
- Navigates after 800ms-10s timeout

**Auth Routes (signin/signup):**

- Accessible to unauthenticated users
- Redirect to `/home` if already authenticated

**Protected Routes (home/games/profile/settings):**

- Require authentication
- Redirect to `/signin` if not authenticated
- Monitored by GoRouter's `refreshListenable`

### State Preservation

**Bottom Navigation Tabs:**

- Each branch uses `StatefulShellBranch`
- Maintains widget tree when switching tabs
- Scroll positions preserved
- Form input preserved
- BLoC state preserved per tab

**Example:**

```
User on Home tab → scrolls to item 50
User taps Games tab → switches to Games
User taps Home tab → returns to scroll position at item 50
```

### Router Testing

**Test Coverage:**

- Route constants validation
- Initial route (/splash)
- All route paths accessible
- Named route navigation
- Auth redirects
- Error screen display

**Related Tests:**

- `test/core/utils/app_router_test.dart`
- `test/core/widgets/bottom_nav_bar_test.dart`

### Related Documentation

- [Splash Feature](../../features/splash/CLAUDE.md) - Initial auth check
- [Profile Feature](../../features/profile/CLAUDE.md) - Profile tab
- [Games Feature](../../features/games/CLAUDE.md) - Games tab placeholder
- [Home Feature](../../features/home/CLAUDE.md) - Home tab
- [App Architecture](../../CLAUDE.md) - Overall patterns
