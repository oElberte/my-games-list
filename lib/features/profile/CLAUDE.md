# Profile Feature

## Overview

The Profile feature provides a user-facing screen displaying authenticated user information with quick access to settings. It serves as one of the three main navigation tabs in the bottom navigation bar.

## Architecture

### Components

- **ProfileScreen**: Displays user information fetched from `AuthBloc`
- **\_InfoRow**: Private widget for displaying labeled user info fields

### Dependencies

- **AuthBloc**: Global BLoC providing user authentication state
- **GoRouter**: For navigation to settings page

## UI Structure

```
ProfileScreen (Scaffold)
├── AppBar
│   ├── Title: "Profile"
│   └── Actions: [Settings IconButton]
└── Body: BlocBuilder<AuthBloc>
    ├── CircleAvatar (User icon)
    ├── Card (User Information)
    │   ├── _InfoRow (Username)
    │   └── _InfoRow (Email)
    └── Fallback: "No user information available"
```

## Key Features

### User Information Display

**Displays:**

- User avatar (Material Design person icon in CircleAvatar)
- Username with account circle icon
- Email address with email icon

**Data Source:**

- All data comes from `AuthBloc.state.user`
- Automatically updates when auth state changes
- Uses `BlocBuilder` for reactive updates

### Settings Navigation

**Gear Icon:**

- Location: AppBar actions (top-right)
- Icon: `Icons.settings`
- Action: Navigates to `/settings` route via `context.go()`
- Tooltip: "Settings"

**Navigation Flow:**

```
Profile Screen → Settings Icon Tap → /settings
Settings Screen ← Back Button ← Returns to /profile
```

## State Management

**No dedicated BLoC** - Profile screen is presentation-only and reads from existing global `AuthBloc`.

**BlocBuilder Pattern:**

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthAuthenticated) {
      final user = state.user;
      // Display user info
    }
    // Fallback for non-authenticated
  },
)
```

## UI Components

### User Avatar

- `CircleAvatar` with 60px radius
- Uses theme `primaryContainer` for background
- Person icon (60px) with `onPrimaryContainer` color
- Material 3 themed colors

### Information Card

- Material `Card` with elevation 2
- Padding: 24px all sides
- Contains two `_InfoRow` widgets

### \_InfoRow Widget

**Purpose:** Reusable labeled info display

**Structure:**

- Icon (24px, primary color)
- Label (labelMedium, onSurfaceVariant)
- Value (bodyLarge, fontWeight 500)

**Used for:**

- Username field
- Email field

## Navigation Integration

### Bottom Navigation

- Profile is **Tab 3** in the bottom navigation bar
- Icon: `Icons.person_outline` (unselected), `Icons.person` (selected)
- Label: "Profile"
- Route: `/profile`

### Settings Access

- Accessible via gear icon in AppBar
- Settings screen is **outside** bottom navigation shell
- Settings has back button that returns to `/profile`

## Testing Strategy

**Test Coverage:**

- ✅ AppBar displays "Profile" title
- ✅ Settings icon present in AppBar
- ✅ CircleAvatar and person icon rendered
- ✅ Username displayed from AuthBloc
- ✅ Email displayed from AuthBloc
- ✅ Card and info rows rendered
- ✅ Icons for username and email fields
- ✅ Navigation to settings on gear icon tap
- ✅ Fallback text when not authenticated
- ✅ Reactive updates when auth state changes
- ✅ Settings tooltip present

## Integration Points

### Router Configuration

```dart
// Profile tab in StatefulShellRoute
StatefulShellBranch(
  routes: [
    GoRoute(
      path: profilePath,
      name: profileName,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
),
```

### AuthBloc Integration

**Requirements:**

- `AuthBloc` must be provided at app level
- Profile screen reads `AuthBloc.state.user`
- Listens for state changes via `BlocBuilder`

**Expected User Model:**

```dart
User(
  id: String,
  email: String,
  name: String,  // Displayed as "Username"
)
```

## Future Enhancements

1. **Profile Picture Upload**: Allow users to upload custom avatars
2. **Additional User Info**: Display join date, game count, favorites
3. **Edit Profile**: Add inline editing for username
4. **Achievements/Stats**: Show user gaming statistics
5. **Friends List**: Display social connections
6. **Theme Preview**: Show current theme selection

## Usage Notes

**For Developers:**

- Profile screen is **read-only** - no mutations
- User updates should happen in Settings screen
- Profile automatically reflects AuthBloc state
- No local state management needed

**Design Patterns:**

- Uses Material 3 components and theming
- Follows consistent icon + label pattern
- Card-based layout for information grouping
- Responsive to theme changes (dark mode)

## Related Documentation

- [Auth Feature](../auth/CLAUDE.md) - User authentication and AuthBloc
- [Settings Feature](../settings/CLAUDE.md) - User settings management
- [Core Navigation](../../core/CLAUDE.md) - Bottom navigation and routing
- [App Architecture](../../CLAUDE.md) - Overall app structure
