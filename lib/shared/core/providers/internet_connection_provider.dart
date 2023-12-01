import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/internet_connection_state_notifier.dart';

final StateNotifierProvider<InternetConnectionStatus, ConnectivityStatus>
    internetConnectionStatusProviders = StateNotifierProvider((ref) {
  return InternetConnectionStatus();
});
