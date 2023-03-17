import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/deep_link_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/remote_config_service/remote_config_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/tadabbur_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class SplashPageState {}

class SplashPageStateNotifier extends BaseStateNotifier<SplashPageState> {
  SplashPageStateNotifier({
    required AuthenticationService authenticationService,
    required RemoteConfigService remoteConfigService,
    required DeepLinkService deepLinkService,
    required TadabburService tadabburService,
    required this.navigatorKey,
  })  : _authenticationService = authenticationService,
        _remoteConfigService = remoteConfigService,
        _tadabburService = tadabburService,
        _deepLinkService = deepLinkService,
        super(
          SplashPageState(),
        );

  final AuthenticationService _authenticationService;
  final RemoteConfigService _remoteConfigService;
  final DeepLinkService _deepLinkService;
  final TadabburService _tadabburService;
  final GlobalKey<NavigatorState> navigatorKey;
  final DbLocal db = DbLocal();

  @override
  Future<void> initStateNotifier() async {
    final Connectivity conn = Connectivity();
    final ConnectivityResult res = await conn.checkConnectivity();

    await _deepLinkService.init(navigatorKey);
    await _authenticationService.initRepository();

    if (res != ConnectivityResult.none) {
      await _tadabburService.syncTadabburPerAyahInformations();
      await _remoteConfigService.init();
    }
  }
}
