import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks whether the device has a network connection: `true` (online) when any
/// connectivity interface is active, `false` when there is none. This reflects
/// interface availability — the standard signal for an offline banner — not
/// full internet reachability.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._connectivity) : super(true) {
    _subscription = _connectivity.onConnectivityChanged.listen(_update);
    unawaited(_init());
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _init() async {
    try {
      _update(await _connectivity.checkConnectivity());
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
