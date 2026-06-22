# Settings Feature Documentation

## Overview
Manages application settings, user preferences, and profile configuration.

## Architecture
**Feature-First Structure**:
- `settings_screen.dart`: Main settings UI.
- `bloc/`: Contains `SettingsBloc` and `AccountManagementBloc` (+ their events/states).
- `services/account_export_saver.dart`: Platform-aware delivery of the data export
  (browser download on web, share-a-file on mobile/desktop) via conditional import.
- `widgets/delete_account_dialog.dart`: Type-to-confirm destructive dialog.

### Dependencies
- `SettingsBloc` (Global/Lazy Singleton): Manages app-wide settings.
- `AccountManagementBloc` (Route-scoped): Drives the LGPD export/delete actions.
  Provided by the settings route; depends on `AuthRepository`.

## Key Components
- **SettingsBloc**: Handles theme switching and other global preferences.
- **AccountManagementBloc**: Calls `AuthRepository.exportData()` /
  `deleteAccount()` and tracks per-action loading/success/error.
- **SettingsScreen**: Dark mode, language, user info, and the
  "Privacy & data" section (export + delete).

## Account deletion / data export (LGPD)
- **Export**: `GET /users/me/export` → JSON delivered via `AccountExportSaver`.
- **Delete**: `DELETE /users/me` (204). On success the screen dispatches
  `AuthLogoutRequested`; the central `SessionResetService` tears down the
  session and the router redirects to sign-in. Deletion is never done inside a
  widget — the bloc owns the call, the UI owns the confirm + teardown dispatch.

## Testing Strategy
- Unit test `SettingsBloc`.
- Verify persistence of settings changes.
