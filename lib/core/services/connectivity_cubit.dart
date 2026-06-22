import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks whether the device has a network connection: `true` (online) when any
/// connectivity interface is active, `false` when there is none. This reflects
/// interface availability — the standard signal for an offline banner — not
/// full internet reachability.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._connectivity) : super(true) {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        _receivedStreamEvent = true;
        _update(results);
      },
      // Ignore stream activation/runtime errors (e.g. a transient platform
      // failure); the next event corrects the state.
      onError: (Object _) {},
    );
    unawaited(_init());
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _receivedStreamEvent = false;

  Future<void> _init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      // A slow initial check must not overwrite a stream event that already
      // arrived (e.g. the connection dropped while the check was in flight).
      if (!_receivedStreamEvent) _update(results);
    } catch (_) {
      // Assume online if the initial check fails; the stream corrects it.
    }
  }

  void _update(List<ConnectivityResult> results) {
    if (isClosed) return;
    emit(results.any((result) => result != ConnectivityResult.none));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
