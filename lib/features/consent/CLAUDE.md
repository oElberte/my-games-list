# Consent Feature

User-facing consent UI (LGPD). This feature only *consumes* the gating
mechanism — `ConsentService` (`lib/core/services/consent/`) owns persistence and
the collector side-effects. Nothing here re-implements gating.

## Pieces
- `bloc/consent_cubit.dart` — thin view over `ConsentService`. Reflects its
  state, stays in sync via the service's `changes` stream (so an external revoke
  like logout updates the UI), and forwards every action to the service.
- `widgets/consent_banner.dart` — `ConsentBanner` wraps the app (mounted in
  `MaterialApp.router`'s `builder`) and shows a non-modal first-run banner
  pinned to the bottom until the user chooses. Shows on every platform incl.
  web. Accept all / Reject all / Customize.
- `widgets/consent_customize_sheet.dart` — per-category switch sheet; returns
  the chosen map to the banner on Save (does not touch the service directly).
- `widgets/consent_settings_section.dart` — per-category `SwitchListTile`s for
  the Settings screen; each flip calls `ConsentCubit.setCategory`.
- `consent_category_l10n.dart` — shared category → localized label mapping.

## Wiring
- `ConsentCubit` is a lazy singleton in the service locator, provided once at the
  app root, shared by the banner and the settings toggles so both stay in sync.
- "Has the user answered?" is persisted by `ConsentService`
  (`hasAnswered` / `markAnswered()`, key `consent_answered`). `revokeAll()`
  clears it so the next account on a shared device is prompted again.

## Testing note
The cubit drives rebuilds via the service's broadcast stream. In widget tests
create it inside `BlocProvider.create` (the test's async zone) — a cubit built
in `setUp` schedules its stream emits on the wrong zone and the `BlocBuilder`
never rebuilds under the fake clock.
