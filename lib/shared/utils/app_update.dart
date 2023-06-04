import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/models/app_update_info.dart';
import 'package:qurantafsir_flutter/shared/core/services/remote_config_service/remote_config_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:version/version.dart';

class AppUpdateUtil {
  static Future<AppUpdateInfo?> showAppUpdateStatus({
    required BuildContext context,
    required RemoteConfigService remoteConfigService,
    required SharedPreferenceService sharedPreferenceService,
    required Version currentVersion,
  }) async {
    final Version forceUpdateMinVersion = Version.parse(
      remoteConfigService.forceUpdateMinVersion,
    );

    if (currentVersion < forceUpdateMinVersion) {
      return AppUpdateInfo(
        type: AppUpdateType.forceUpdate,
        currentVersion: currentVersion,
      );
    }

    final Version optionalUpdateMinVersion = Version.parse(
      remoteConfigService.optionalUpdateMinVersion,
    );

    final String shownOptionalUpdateMinVersion =
        sharedPreferenceService.getShownOptionalUpdateMinVersion();

    if (currentVersion < optionalUpdateMinVersion) {
      return AppUpdateInfo(
        type: AppUpdateType.optionalUpdate,
        optionalUpdateMinVersion: optionalUpdateMinVersion,
        shouldShowUpdateMinVersion: shownOptionalUpdateMinVersion !=
            optionalUpdateMinVersion.toString(),
      );
    }

    return null;
  }
}
