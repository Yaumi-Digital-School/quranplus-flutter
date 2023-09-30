import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/internet_connection_state_notifier.dart';

final internetConnectionStatusProviders = StateNotifierProvider((ref) {
  return InternetConnectionStatus();
});
