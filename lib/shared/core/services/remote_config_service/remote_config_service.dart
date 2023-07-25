import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:qurantafsir_flutter/firebase_options.dart';
import 'package:qurantafsir_flutter/shared/core/services/remote_config_service/constants.dart';

class RemoteConfigService {
  FirebaseRemoteConfig? _remoteConfig;

  Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 0),
      ));

      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      print(e);
    }
  }

  /*
    VALUE GETTER
  */

  int get syncTadabburDataIntervalInDays =>
      _remoteConfig?.getInt(
        RemoteConfigKey.syncTadabburDataIntervalInDays,
      ) ??
      1;

  String get forceUpdateMinVersion =>
      _remoteConfig?.getString(
        RemoteConfigKey.forceUpdateMinVersion,
      ) ??
      '';

  String get optionalUpdateMinVersion =>
      _remoteConfig?.getString(
        RemoteConfigKey.optionalUpdateMinVersion,
      ) ??
      '';
}
