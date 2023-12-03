import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';

class InternetConnectionStatus extends StateNotifier<ConnectivityStatus> {
  late ConnectivityStatus lastResult;
  late ConnectivityStatus newState;

  InternetConnectionStatus() : super(ConnectivityStatus.isConnected) {
    lastResult = state;
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.ethernet:
        case ConnectivityResult.mobile:
        case ConnectivityResult.wifi:
          newState = ConnectivityStatus.isConnected;
          break;
        default:
          newState = ConnectivityStatus.isDisconnected;
          break;
      }
      if (newState != lastResult) {
        state = newState;
        lastResult = newState;
      }
    });
  }
}
