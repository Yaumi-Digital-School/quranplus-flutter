import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/apis/tadabbur_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/db_local.dart';
import 'package:qurantafsir_flutter/shared/core/services/remote_config_service/remote_config_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:retrofit/retrofit.dart';

class TadabburService {
  TadabburService({
    required TadabburApi tadabburApi,
    required SharedPreferenceService sharedPreferenceService,
    required RemoteConfigService remoteConfigService,
  })  : _tadabburApi = tadabburApi,
        _remoteConfigService = remoteConfigService,
        _sharedPreferenceService = sharedPreferenceService;

  final TadabburApi _tadabburApi;
  final SharedPreferenceService _sharedPreferenceService;
  final RemoteConfigService _remoteConfigService;
  final DbLocal _db = DbLocal();

  Future<void> syncTadabburPerAyahInformations() async {
    final String lastSyncInStr =
        _sharedPreferenceService.getLastSyncTadabburInformation();

    final DateTime curr = DateTime.now();
    if (lastSyncInStr != '') {
      final DateTime lastSync = DateTime.parse(lastSyncInStr);

      final int intervalShouldSync =
          _remoteConfigService.syncTadabburDataIntervalInDays;

      if (curr.difference(lastSync).inDays < intervalShouldSync) {
        return;
      }
    }

    try {
      HttpResponse<dynamic> response =
          await _tadabburApi.getListOfAvailableTadabburAyah();
      if (response.response.statusCode == 200) {
        final Map<String, List<dynamic>> res =
            Map<String, List<dynamic>>.from(response.response.data);

        final Map<int, List<int>> resParsed = res.map((key, value) {
          return MapEntry(int.tryParse(key) ?? 0, List<int>.from(value));
        });

        await _db.bulkReplaceTadabburAyahAvailables(resParsed);
        await syncTadabburSurahInformation();

        _sharedPreferenceService.setLastSyncTadabburInformation(curr);
      }
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on syncTadabburPerAyahInformations() method',
      );

      return;
    }
  }

  Future<void> syncTadabburSurahInformation() async {
    HttpResponse<List<GetTadabburSurahListItemResponse>> taddaburAvailable =
        await _tadabburApi.getAvailableTadabburSurahList();

    if (taddaburAvailable.response.statusCode == 200) {
      Map<int, int> tadabburSurahMap = {
        for (var surah in taddaburAvailable.data)
          surah.surahID: surah.totalTadabbur,
      };
      await _db.bulkReplaceTadabburSurahAvailables(tadabburSurahMap);
    }
  }
}
