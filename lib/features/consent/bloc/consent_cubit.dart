import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:my_games_list/core/services/consent/consent_category.dart';
import 'package:my_games_list/core/services/consent/consent_service.dart';
import 'package:my_games_list/features/consent/bloc/consent_state.dart';

/// Thin presentation layer over [ConsentService].
///
/// Keeps consent logic out of widgets: it reflects the service's current state,
/// stays in sync with the service's [ConsentService.changes] stream (so a
/// revoke triggered elsewhere, e.g. logout teardown, updates the UI), and
/// forwards every user action straight to the service, which owns persistence
/// and the collector side-effects.
class ConsentCubit extends Cubit<ConsentState> {
  ConsentCubit(this._service)
    : super(
        ConsentState(
          hasAnswered: _service.hasAnswered,
          granted: _snapshot(_service),
        ),
      ) {
    _subscription = _service.changes.listen((_) => _sync());
  }

  final ConsentService _service;
  late final StreamSubscription<ConsentCategory> _subscription;

  static Map<ConsentCategory, bool> _snapshot(ConsentService service) => {
    for (final category in ConsentCategory.values)
      category: service.isGranted(category),
  };

  void _sync() {
    emit(
      ConsentState(
        hasAnswered: _service.hasAnswered,
        granted: _snapshot(_service),
      ),
    );
  }

  /// Sets a single category's consent and records that the user has answered.
  /// Used by the settings switches.
  Future<void> setCategory(
    ConsentCategory category, {
    required bool granted,
  }) async {
    if (granted) {
      await _service.grant(category);
    } else {
      await _service.revoke(category);
    }
    await _service.markAnswered();
    _sync();
  }

  /// Grants every category (first-run "Accept all").
  Future<void> acceptAll() async {
    for (final category in ConsentCategory.values) {
      await _service.grant(category);
    }
    await _service.markAnswered();
    _sync();
  }

  /// Denies every category (first-run "Reject all"). Collection stays off.
  Future<void> rejectAll() async {
    for (final category in ConsentCategory.values) {
      await _service.revoke(category);
    }
    await _service.markAnswered();
    _sync();
  }

  /// Applies a per-category map from the first-run "Customize" sheet.
  Future<void> applyChoices(Map<ConsentCategory, bool> choices) async {
    for (final entry in choices.entries) {
      if (entry.value) {
        await _service.grant(entry.key);
      } else {
        await _service.revoke(entry.key);
      }
    }
    await _service.markAnswered();
    _sync();
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
