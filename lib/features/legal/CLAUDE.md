# Legal Feature

Privacy Policy & Terms of Service screens plus the required consent gate at sign-up.

## What's here

- `legal_constants.dart` — `kConsentVersion`, the single source of truth for the
  accepted documents' version. Sent to the API as `consent_version` on signup
  and Google/social auth (the API requires it on both, `binding:"required"`).
  Bump it whenever the legal text materially changes.
- `legal_document.dart` — `LegalDocument` enum mapping each document to its
  per-locale asset under `assets/legal/`.
- `presentation/legal_document_screen.dart` — renders a document from its
  locale asset via `rootBundle`, with a localized DRAFT banner.
- `presentation/legal_acceptance_checkbox.dart` — the sign-up consent control
  with tappable Privacy Policy / Terms links.

## Conventions / gotchas

- **Placeholder text.** The document bodies in `assets/legal/*.md` are DRAFT
  placeholders. Replace them and `kConsentVersion` with the real legal text +
  DPO contact (issue #26 / api#26).
- **Why assets, not l10n.** The long body lives in assets so it never becomes an
  inline `Text('...')` literal that `tool/check_hardcoded_strings.sh` would flag.
  Only titles, the checkbox label fragments, and the DRAFT banner go through
  `context.l10n`.
- **Routing.** `/privacy-policy` and `/terms` are top-level GoRoutes (outside the
  shell) and are allow-listed in the router redirect so they're reachable while
  unauthenticated (the sign-up gate links to them before an account exists).
- **Consent gate.** The Sign Up button is disabled until the checkbox is ticked;
  `SignUpBloc` also refuses to submit (and emits `SignUpTermsNotAccepted`) if an
  unaccepted submission arrives — the rule lives in the bloc, not the widget.
