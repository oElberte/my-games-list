# Splash Feature

## Overview

The Splash feature provides the initial loading screen for the application, handling authentication state checks before navigating users to the appropriate screen.

## Architecture

### Components

- **SplashScreen**: Stateful widget that displays app branding while checking authentication status

### Dependencies

- **AuthBloc**: Global BLoC used to load and listen to authentication state
- **GoRouter**: For navigation after authentication check completes

## Key Behavior

### Timing Strategy

The splash screen implements a balanced timing strategy:

1. **Minimum Display Duration**: 800ms
   - Ensures users see the app branding even on fast connections
   - Prevents jarring flash of splash screen
   - Provides professional, polished UX

2. **Maximum Timeout Duration**: 10 seconds
   - Protects against hung authentication checks
   - After timeout, shows error screen with retry option
   - Prevents users from being stuck indefinitely

### Authentication Flow

```
App Start
    ↓
Splash Screen Shown
    ↓
Dispatch AuthStateLoaded event
    ↓
Wait for AuthBloc state change
    ├─→ AuthAuthenticated → Navigate to /home (after min 800ms)
    ├─→ AuthUnauthenticated → Navigate to /signin (after min 800ms)
    ├─→ AuthError → Navigate to /signin (after min 800ms)
    └─→ Timeout (10s) → Show error with retry button
```

### State Management

**Splash screen manages:**

- `_hasTimedOut`: Boolean flag for timeout state
- `_hasNavigated`: Prevents multiple navigation attempts
- `_splashStartTime`: Tracks display duration for minimum wait
- `_timeoutTimer`: Timer for 10-second timeout

### Error Handling

**Timeout Behavior:**

- After 10 seconds with no auth response, shows error UI
- Displays error icon, message, and "Try Again" button
- Retry button:
  - Resets all state flags
  - Restarts timeout timer
  - Re-dispatches `AuthStateLoaded` event
  - Returns to loading view

**Auth Error Behavior:**

- Treats auth errors as unauthenticated state
- Navigates to sign-in page
- Allows user to attempt login again

## UI Components

### Loading View

- App icon (`Icons.games`)
- App name from localization
- Circular progress indicator
- Centered layout with vertical column

### Timeout/Error View

- Error icon (`Icons.error_outline`)
- Error title from localization
- Descriptive message about timeout
- "Try Again" button with refresh icon
- Padded layout for readability

## Testing Strategy

**Test Coverage:**

- ✅ UI rendering (icon, name, loading indicator)
- ✅ AuthStateLoaded event dispatch on init
- ✅ Timeout after 10 seconds
- ✅ Retry functionality
- ✅ Minimum 800ms display duration enforcement
- ✅ Navigation to home on authenticated
- ✅ Navigation to signin on unauthenticated
- ✅ Navigation to signin on auth error

## Integration Points

### Router Integration

Splash screen is the **initial location** for the app:

- Route: `/splash`
- No route guards (splash needs to run before auth checks)
- After auth check, router redirect logic takes over

### AuthBloc Integration

The splash screen:

1. Listens to `AuthBloc` state stream via `BlocListener`
2. Dispatches `AuthStateLoaded` to trigger state restoration
3. Navigates based on received state

## Future Considerations

1. **Loading Progress**: Could add progress indicator for slower connections
2. **Animated Branding**: Consider fade-in/scale animations for logo
3. **Network Connectivity Check**: Detect offline state before timeout
4. **Configurable Timeouts**: Make min/max durations configurable via settings
5. **Analytics**: Track splash screen duration and timeout frequency

## Usage Notes

**For Developers:**

- Splash screen runs once per app session
- Always dispatches `AuthStateLoaded` event
- Minimum duration ensures smooth UX
- Timeout prevents indefinite hangs

**Router Configuration:**

```dart
// In app_router.dart
initialLocation: AppRouter.splashPath,

// Splash route
GoRoute(
  path: splashPath,
  name: splashName,
  builder: (context, state) => const SplashScreen(),
),
```

**State Dependencies:**

- Requires `AuthBloc` to be provided at app level
- Uses localization (l10n) for all text

## Related Documentation

- [Auth Feature](../auth/CLAUDE.md) - Authentication state management
- [Core Navigation](../../core/CLAUDE.md) - Router configuration and shell navigation
- [App Architecture](../../CLAUDE.md) - Overall app structure
