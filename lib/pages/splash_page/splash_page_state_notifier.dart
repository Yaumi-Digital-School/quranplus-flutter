import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qurantafsir_flutter/main.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/core/models/app_update_info.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/utils/app_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:version/version.dart';

part 'splash_page_state_notifier.g.dart';

class SplashPageState {}

@riverpod
class SplashPageNotifier extends _$SplashPageNotifier {
  @override
  SplashPageState build() => SplashPageState();

  Future<void> initStateNotifier({
    ConnectivityStatus? connectivityStatus,
  }) async {
    final auth = ref.read(authenticationService);
    final deepLink = ref.read(deepLinkService);
    final prayerTimes = ref.read(prayerTimesService);
    final remoteConfig = ref.read(remoteConfigService);
    final tadabbur = ref.read(tadabburService);
    final habitSummary = ref.read(habitDailySummaryService);

    try {
      await deepLink.init(navigatorKey);
      await auth.initRepository();
      prayerTimes.init();

      if (connectivityStatus == ConnectivityStatus.isConnected) {
        await remoteConfig.init();
        await tadabbur.syncTadabburPerAyahInformations();
        unawaited(auth.ping());

        if (auth.isLoggedIn) {
          await habitSummary.syncHabit();
        }
      }
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on initstate() method in splash screen',
      );
      debugPrint(error.toString());
    }
  }

  Future<AppUpdateInfo?> getAppUpdateStatus({
    required BuildContext context,
    required ConnectivityStatus connectivityStatus,
  }) async {
    if (connectivityStatus != ConnectivityStatus.isConnected) return null;

    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return null;

    return AppUpdateUtil.showAppUpdateStatus(
      context: context,
      remoteConfigService: ref.read(remoteConfigService),
      currentVersion: Version.parse(info.version),
      sharedPreferenceService: ref.read(sharedPreferenceServiceProvider),
    );
  }
}
