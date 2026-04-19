import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';

class InternetConnectionStatus extends StateNotifier<ConnectivityStatus> {
  late ConnectivityStatus lastResult;
  late ConnectivityStatus newState;

  InternetConnectionStatus() : super(ConnectivityStatus.isConnected) {
    lastResult = state;
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final bool hasConnection = results.any((r) =>
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi);
      newState = hasConnection
          ? ConnectivityStatus.isConnected
          : ConnectivityStatus.isDisconnected;
      if (newState != lastResult) {
        state = newState;
        lastResult = newState;
      }
    });
  }
}
