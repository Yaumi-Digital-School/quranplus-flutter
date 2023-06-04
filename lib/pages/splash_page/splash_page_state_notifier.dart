import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
import 'package:qurantafsir_flutter/shared/core/models/app_update_info.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/deep_link_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/habit_daily_summary_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/remote_config_service/remote_config_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/tadabbur_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/app_update.dart';
import 'package:version/version.dart';

class SplashPageState {}

class SplashPageStateNotifier extends BaseStateNotifier<SplashPageState> {
  SplashPageStateNotifier({
    required AuthenticationService authenticationService,
    required RemoteConfigService remoteConfigService,
    required HabitDailySummaryService habitDailySummaryService,
    required SharedPreferenceService sharedPreferenceService,
    required DeepLinkService deepLinkService,
    required TadabburService tadabburService,
    required this.navigatorKey,
  })  : _authenticationService = authenticationService,
        _remoteConfigService = remoteConfigService,
        _habitDailySummaryService = habitDailySummaryService,
        _tadabburService = tadabburService,
        _sharedPreferenceService = sharedPreferenceService,
        _deepLinkService = deepLinkService,
        super(
          SplashPageState(),
        );

  final AuthenticationService _authenticationService;
  final SharedPreferenceService _sharedPreferenceService;
  final RemoteConfigService _remoteConfigService;
  final DeepLinkService _deepLinkService;
  final TadabburService _tadabburService;
  final HabitDailySummaryService _habitDailySummaryService;
  final GlobalKey<NavigatorState> navigatorKey;
  final DbLocal db = DbLocal();

  late AppUpdateType? appUpdateType;

  @override
  Future<void> initStateNotifier({
    ConnectivityResult? conn,
  }) async {
    await _deepLinkService.init(navigatorKey);
    await _authenticationService.initRepository();

    if (conn != null && conn != ConnectivityResult.none) {
      await _remoteConfigService.init();
      await _tadabburService.syncTadabburPerAyahInformations();

      if (_authenticationService.isLoggedIn) {
        await _habitDailySummaryService.syncHabit();
      }
    }
  }

  Future<AppUpdateInfo?> getAppUpdateStatus({
    required BuildContext context,
    required ConnectivityResult conn,
  }) async {
    AppUpdateInfo? appUpdateInfo;

    if (conn != ConnectivityResult.none) {
      PackageInfo info = await PackageInfo.fromPlatform();

      appUpdateInfo = await AppUpdateUtil.showAppUpdateStatus(
        context: context,
        remoteConfigService: _remoteConfigService,
        currentVersion: Version.parse(info.version),
        sharedPreferenceService: _sharedPreferenceService,
      );
    }

    return appUpdateInfo;
  }
}
