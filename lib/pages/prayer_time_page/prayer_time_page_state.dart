import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/adhan_config.dart';
import 'package:qurantafsir_flutter/shared/utils/geolocation_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/core/services/shared_preference_service.dart';
import '../../shared/core/state_notifiers/base_state_notifier.dart';
import '../../shared/utils/prayer_alarm_helper.dart';
import '../../shared/utils/prayer_time_helper.dart';

class PrayerTimePageState {
  String isha;
  String fajr;
  String dhuhr;
  String ashr;
  String maghrib;

  PrayerTimePageState({
    this.isha = '__:__',
    this.fajr = '__:__',
    this.dhuhr = '__:__',
    this.ashr = '__:__',
    this.maghrib = '__:__',
  });

  PrayerTimePageState copyWith({
    String? isha,
    String? fajr,
    String? dhuhr,
    String? ashr,
    String? maghrib,
  }) {
    return PrayerTimePageState(
      isha: isha ?? this.isha,
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      ashr: ashr ?? this.ashr,
      maghrib: maghrib ?? this.maghrib,
    );
  }
}

class PrayerTimeStateNotifier extends BaseStateNotifier<PrayerTimePageState> {
  PrayerTimeStateNotifier() : super(PrayerTimePageState());

  @override
  initStateNotifier() async {
    // TODO: implement initStateNotifier
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('latitude') && prefs.containsKey('longitude')) {
      final params = await getPrayerParams();
      Coordinates _myCoordinates = await getSavedCoordinates();
      PrayerTimes _prayerTimes = PrayerTimes.today(_myCoordinates, params);

      state = state.copyWith(
        fajr: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.fajr)),
        dhuhr: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.dhuhr)),
        ashr: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.asr)),
        maghrib: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.maghrib)),
        isha: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.isha)),
      );
    }
  }

  Future<void> getPrayerTimes() async {
    List<bool> alarmFlag = Prayer.values.map((v) {
      return false;
    }).toList();
    final params = await getPrayerParams();
    Coordinates _myCoordinates = await getCoordinates();
    PrayerTimes _prayerTimes = PrayerTimes.today(_myCoordinates, params);
    savePrayerParams(CalculationMethod.karachi.index, Madhab.shafi.index);

    Prayer.values.forEach((p) async {
      alarmFlag[p.index] = await getAlarmFlag(p.index);
      setAlarmNotification(_prayerTimes, p.index, alarmFlag[p.index]);
    });

    state = state.copyWith(
      fajr: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.fajr)),
      dhuhr: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.dhuhr)),
      ashr: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.asr)),
      maghrib: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.maghrib)),
      isha: _formatDateTime(_prayerTimes.timeForPrayer(Prayer.isha)),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return formattedTime;
  }
}
