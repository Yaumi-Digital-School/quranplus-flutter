import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:version/version.dart';

class AppUpdateInfo {
  AppUpdateInfo({
    required this.type,
    this.optionalUpdateMinVersion,
    this.currentVersion,
    this.shouldShowUpdateMinVersion = false,
  });

  final Version? optionalUpdateMinVersion;
  final Version? currentVersion;
  final bool shouldShowUpdateMinVersion;
  final AppUpdateType type;
}
