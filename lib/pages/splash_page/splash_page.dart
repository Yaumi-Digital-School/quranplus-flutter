import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/splash_page/splash_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/models/app_update_info.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/internet_utils.dart';
import 'package:qurantafsir_flutter/widgets/app_update/force_update_dialog.dart';
import 'package:qurantafsir_flutter/widgets/app_update/optional_update_dialog.dart';
import 'package:qurantafsir_flutter/widgets/utils/general_dialog.dart';

class SplashPage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const SplashPage({required this.navigatorKey, Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<SplashPageStateNotifier, SplashPageState>(
      stateNotifierProvider:
          StateNotifierProvider<SplashPageStateNotifier, SplashPageState>(
        (ref) {
          return SplashPageStateNotifier(
            deepLinkService: ref.watch(deepLinkService),
            authenticationService: ref.watch(authenticationService),
            navigatorKey: widget.navigatorKey,
            tadabburService: ref.read(tadabburService),
            remoteConfigService: ref.read(remoteConfigService),
            habitDailySummaryService: ref.read(habitDailySummaryService),
            sharedPreferenceService: ref.read(sharedPreferenceServiceProvider),
          );
        },
      ),
      onStateNotifierReady: (notifier, _) async {
        bool isConnected = await InternetUtils.isInternetAvailable();

        await notifier.initStateNotifier(
          isConnected: isConnected,
        );

        AppUpdateInfo? updateInfo = await notifier.getAppUpdateStatus(
          context: context,
          isConnected: isConnected,
        );
        if (updateInfo != null) {
          await buildAppUpdateDialog(updateInfo);
        }

        Navigator.of(context).pushReplacementNamed(RoutePaths.routeMain);
      },
      builder: (
        _,
        SplashPageState state,
        SplashPageStateNotifier notifier,
        __,
      ) {
        return Scaffold(
          body: Center(
            child: Image.asset(
              ImagePath.logoQuranPlusPotrait,
              color: Theme.of(context).colorScheme.primary,
              width: 92,
              height: 110,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Future<void> buildAppUpdateDialog(
    AppUpdateInfo info,
  ) async {
    late Widget dialog;
    switch (info.type) {
      case AppUpdateType.forceUpdate:
        dialog = const ForceUpdateDialog();
        break;
      case AppUpdateType.optionalUpdate:
      default:
        if (!info.shouldShowUpdateMinVersion) {
          return;
        }

        dialog = OptionalUpdateDialog(
          optionalMinVersion: info.optionalUpdateMinVersion!,
        );
    }

    await showQPGeneralDialog(
      isBarrierDismissable: false,
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }
}
