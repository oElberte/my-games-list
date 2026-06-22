# Onboarding Feature

First-run welcome flow, shown once per install before the user reaches the app.

## Pieces

- `onboarding_service.dart` — reads/writes the one-time `onboarding_completed`
  bool through `LocalStorageService`. Defaults to "not completed" on any read
  failure so a fresh install never silently skips onboarding.
- `onboarding_page_data.dart` — pure value object for one intro page (icon +
  localized title/subtitle selectors). No `BuildContext`, so the page list stays
  `const`.
- `onboarding_screen.dart` — swipeable `PageView` with a dot indicator, Skip and
  Next/Get-started actions. It owns only presentation and the "mark completed"
  side effect.

## Routing contract

The screen does **not** decide where to go next. Auth state determines the
destination, and only the router knows it, so `OnboardingScreen.onCompleted` is
supplied by `app_router.dart` and navigates to home (authenticated) or sign in.

Flow: splash loads auth → if `onboarding_completed` is unset it routes to
`/onboarding` instead of the auth destination → onboarding persists the flag and
calls `onCompleted`. `/onboarding` is allowlisted in the GoRouter redirect (like
`/splash`) so the auth guard never bounces it.

## Adding a page

Append an `OnboardingPageData` to `_pages` in `onboarding_screen.dart` and add
the matching `onboarding*` keys to **both** `app_en.arb` and `app_pt.arb`, then
`fvm flutter gen-l10n`.
