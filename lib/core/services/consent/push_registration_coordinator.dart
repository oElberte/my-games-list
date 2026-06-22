import 'dart:async';

import 'package:my_games_list/core/services/consent/consent_category.dart';
import 'package:my_games_list/core/services/consent/consent_service.dart';
import 'package:my_games_list/core/services/notification_service.dart';
import 'package:my_games_list/features/auth/bloc/auth_bloc.dart';
import 'package:my_games_list/features/auth/bloc/auth_state.dart';

/// Registers FCM only when push consent is granted **and** the user is
/// authenticated, and tears it down when either condition stops holding.
///
/// This is the seam that fixes the cold-start `PATCH /users/me/fcm-token` 401:
/// the token is never sent on launch. It is sent the moment both gates are
/// satisfied (consent flip while signed in, or sign-in while consent is on).
class PushRegistrationCoordinator {
  PushRegistrationCoordinator({
    required ConsentService consentService,
    required NotificationService notificationService,
    required AuthBloc authBloc,
  }) : _consent = consentService,
       _notifications = notificationService,
       _auth = authBloc;

  final ConsentService _consent;
  final NotificationService _notifications;
  final AuthBloc _auth;

  StreamSubscription<ConsentCategory>? _consentSub;
  StreamSubscription<AuthState>? _authSub;
  bool _registered = false;

  /// Starts watching consent + auth and reconciles the current state once.
  void start() {
    _consentSub = _consent.changes.listen((category) {
      if (category == ConsentCategory.push) _reconcile();
    });
    _authSub = _auth.stream.listen((_) => _reconcile());
    _reconcile();
  }

  void _reconcile() {
    final shouldRegister =
        _consent.isGranted(ConsentCategory.push) &&
        _auth.state is AuthAuthenticated;

    if (shouldRegister && !_registered) {
      _registered = true;
      // Fire-and-forget: failures are handled inside the service (e.g. when
      // Firebase is unavailable in tests).
      _notifications.initialize().catchError((_) {});
    } else if (!shouldRegister && _registered) {
      _registered = false;
      _notifications.disable().catchError((_) {});
    }
  }

  Future<void> dispose() async {
    await _consentSub?.cancel();
    await _authSub?.cancel();
  }
}
