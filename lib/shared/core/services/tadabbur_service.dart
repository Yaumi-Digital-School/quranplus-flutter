import 'package:qurantafsir_flutter/shared/core/apis/tadabbur_api.dart';
import 'package:qurantafsir_flutter/shared/core/database/dbLocal.dart';
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

    HttpResponse<dynamic> response =
        await _tadabburApi.getListOfAvailableTadabburAyah();

    if (response.response.statusCode == 200) {
      final Map<String, List<dynamic>> res =
          Map<String, List<dynamic>>.from(response.response.data);

      final Map<int, List<int>> resParsed = res.map((key, value) {
        return MapEntry(int.tryParse(key) ?? 0, List<int>.from(value));
      });

      await _db.bulkReplaceTadabburAyahAvailables(resParsed);

      _sharedPreferenceService.setLastSyncTadabburInformation(curr);
    }
  }
}
