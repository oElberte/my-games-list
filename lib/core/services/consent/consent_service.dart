import 'dart:async';

import 'package:my_games_list/core/data/services/storage/local_storage_service.dart';
import 'package:my_games_list/core/services/consent/consent_category.dart';
import 'package:my_games_list/core/services/consent/telemetry_gateway.dart';

/// Central gate for all telemetry/marketing data collection (LGPD).
///
/// Consent is persisted per [ConsentCategory] and **defaults to denied** until
/// the user explicitly grants it. Granting/revoking immediately applies the
/// corresponding collector side-effect through the [TelemetryGateway] (e.g.
/// enabling Crashlytics, deleting the FCM token), so revocation actually stops
/// collection rather than only hiding a setting.
///
/// This is the mechanism only — the consent UI (#19) consumes this service to
/// flip categories. The service installs no UI and reads no policy text.
class ConsentService {
  ConsentService({
    required LocalStorageService storage,
    required TelemetryGateway gateway,
  }) : _storage = storage,
       _gateway = gateway;

  final LocalStorageService _storage;
  final TelemetryGateway _gateway;

  final Map<ConsentCategory, bool> _granted = {
    for (final category in ConsentCategory.values) category: false,
  };

  final _changes = StreamController<ConsentCategory>.broadcast();

  /// Emits a category whenever its consent flag changes.
  Stream<ConsentCategory> get changes => _changes.stream;

  /// Loads persisted consent and applies each collector's current state.
  ///
  /// Must be called during startup before any collector is touched. Defaults
  /// every category to denied when storage has no value, then pushes that state
  /// to the gateway so a fresh install collects nothing.
  Future<void> load() async {
    for (final category in ConsentCategory.values) {
      final stored = await _readStored(category);
      _granted[category] = stored;
      await _gateway.applyConsent(category, granted: stored);
    }
  }

  /// Whether the user has granted consent for [category]. Denied by default.
  bool isGranted(ConsentCategory category) => _granted[category] ?? false;

  /// Grants consent for [category], persists it, and enables its collector.
  Future<void> grant(ConsentCategory category) => _set(category, true);

  /// Revokes consent for [category], persists it, and stops/clears its
  /// collector (e.g. disables Crashlytics, deletes the FCM token).
  Future<void> revoke(ConsentCategory category) => _set(category, false);

  /// Revokes consent for every category, persisting denied and tearing down
  /// each collector. Called on logout/session teardown so a shared device does
  /// not leak the previous account's consent to the next account (which would
  /// otherwise inherit it and start collecting). The next account starts
  /// denied and must grant again.
  Future<void> revokeAll() async {
    for (final category in ConsentCategory.values) {
      await _set(category, false);
    }
  }

  Future<void> _set(ConsentCategory category, bool granted) async {
    if (_granted[category] == granted) return;
    _granted[category] = granted;
    await _storage.setBool(category.storageKey, granted);
    await _gateway.applyConsent(category, granted: granted);
    _changes.add(category);
  }

  /// Forwards a Flutter framework error to the gateway only when crash consent
  /// is granted; otherwise it is dropped. Wired to `FlutterError.onError`.
  Future<void> reportFlutterError(FlutterErrorDetailsLike details) async {
    if (!isGranted(ConsentCategory.crash)) return;
    await _gateway.recordFlutterError(details);
  }

  /// Forwards an uncaught platform error to the gateway only when crash consent
  /// is granted; otherwise it is dropped. Wired to `PlatformDispatcher.onError`.
  Future<void> reportError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
  }) async {
    if (!isGranted(ConsentCategory.crash)) return;
    await _gateway.recordError(error, stack, fatal: fatal);
  }

  Future<bool> _readStored(ConsentCategory category) async {
    try {
      return await _storage.getBool(category.storageKey) ?? false;
    } catch (_) {
      // Storage can be unavailable (locked keystore, tests); fail closed.
      return false;
    }
  }

  Future<void> dispose() => _changes.close();
}
