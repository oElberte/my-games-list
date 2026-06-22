/// Single source of truth for the legal documents' consent version.
///
/// Sent to the API as `consent_version` on signup and social auth so the
/// backend can record exactly which Privacy Policy / Terms revision the user
/// accepted. The API stores it in a VARCHAR(32) column and requires it on every
/// account-creating request, so any string up to 32 chars works; we use the
/// publication date of the current documents.
///
/// Bump this whenever the Privacy Policy or Terms text materially changes so a
/// fresh acceptance is recorded against the new revision.
// TODO(#26): Align this value with the real published Privacy Policy / Terms
// revision once the final legal text and DPO contact are supplied.
const String kConsentVersion = '2026-06-22';
