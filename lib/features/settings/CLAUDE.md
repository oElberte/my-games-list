# Settings Feature Documentation

## Overview
Manages application settings, user preferences, and profile configuration.

## Architecture
**Feature-First Structure**:
- `settings_screen.dart`: Main settings UI.
- `bloc/`: Contains `SettingsBloc`, `SettingsEvent`, `SettingsState`.

### Dependencies
- `SettingsBloc` (Global/Lazy Singleton): Manages app-wide settings.

## Key Components
- **SettingsBloc**: Handles theme switching and other global preferences.
- **SettingsScreen**: UI for toggling dark mode and viewing user info.

## Testing Strategy
- Unit test `SettingsBloc`.
- Verify persistence of settings changes.
