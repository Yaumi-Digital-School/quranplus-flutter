import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';

part 'internet_connection_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class InternetConnectionStatus extends _$InternetConnectionStatus {
  late ConnectivityStatus _lastResult;

  @override
  ConnectivityStatus build() {
    _lastResult = ConnectivityStatus.isConnected;

    final subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final bool hasConnection = results.any((r) =>
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi);
      final newState = hasConnection
          ? ConnectivityStatus.isConnected
          : ConnectivityStatus.isDisconnected;
      if (newState != _lastResult) {
        state = newState;
        _lastResult = newState;
      }
    });
    ref.onDispose(subscription.cancel);

    return ConnectivityStatus.isConnected;
  }
}
