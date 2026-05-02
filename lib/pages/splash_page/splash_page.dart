import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/pages/splash_page/splash_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/models/app_update_info.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/utils/prayer_times.dart';
import 'package:qurantafsir_flutter/widgets/app_update/force_update_dialog.dart';
import 'package:qurantafsir_flutter/widgets/app_update/optional_update_dialog.dart';
import 'package:qurantafsir_flutter/widgets/utils/general_dialog.dart';

class SplashPage extends ConsumerStatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const SplashPage({required this.navigatorKey, super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferenceService sharedPref =
          ref.read(sharedPreferenceServiceProvider);
      final String currentDate = DateFormat('yyyy-MM-dd').format(
        DateTime.now(),
      );
      final DateTime currentDateTime = DateTime.parse(currentDate);
      if (sharedPref.getLatestPrayerTimeSynced() == null ||
          (sharedPref.getLatestPrayerTimeSynced() != null &&
              sharedPref
                  .getLatestPrayerTimeSynced()!
                  .isBefore(currentDateTime))) {
        schedulePrayerTimes();
        sharedPref.setLatestPrayerTimeSynced(currentDateTime);
      }

      final connectivityStatus = ref.read(internetConnectionStatusProvider);

      final notifier = ref.read(splashPageProvider.notifier);
      await notifier.initStateNotifier(
        connectivityStatus: connectivityStatus,
      );

      if (!mounted) return;
      AppUpdateInfo? updateInfo = await notifier.getAppUpdateStatus(
        context: context,
        connectivityStatus: connectivityStatus,
      );

      if (updateInfo != null) {
        await buildAppUpdateDialog(updateInfo);
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(RoutePaths.routeMain);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(splashPageProvider);
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
  }

  Future<void> buildAppUpdateDialog(AppUpdateInfo info) async {
    late Widget dialog;
    switch (info.type) {
      case AppUpdateType.forceUpdate:
        dialog = const ForceUpdateDialog();
        break;
      case AppUpdateType.optionalUpdate:
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
