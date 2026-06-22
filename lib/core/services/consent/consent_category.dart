/// Data-collection categories that require explicit user consent (LGPD).
///
/// Each category gates an independent collector. Consent defaults to denied for
/// every category until the user explicitly grants it (see [ConsentService]).
enum ConsentCategory {
  /// Product analytics (usage events). Currently a no-op gate — the app does
  /// not ship `firebase_analytics`. The seam exists so analytics can be wired
  /// later without re-touching the gating mechanism.
  analytics,

  /// Crash and error reporting (Firebase Crashlytics + Flutter error hooks).
  crash,

  /// Push notifications (FCM token registration + OS permission prompt).
  push,
}

extension ConsentCategoryStorageKey on ConsentCategory {
  /// Stable storage key used to persist this category's consent flag.
  String get storageKey => 'consent_$name';
}
