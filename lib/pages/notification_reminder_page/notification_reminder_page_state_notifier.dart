import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/adhan_config.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/core/models/prayer.dart';
import 'package:qurantafsir_flutter/shared/utils/geolocation_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/core/state_notifiers/base_state_notifier.dart';
import '../../shared/utils/prayer_alarm_helper.dart';
import '../../shared/utils/prayer_time_helper.dart';

class NotificationReminderPageState {
  List<PrayerModel>? items;
  PrayerTimes? prayerTimes;

  NotificationReminderPageState({
    this.items,
    this.prayerTimes,
  });

  NotificationReminderPageState copyWith({
    List<PrayerModel>? items,
    PrayerTimes? prayerTimes,
  }) {
    return NotificationReminderPageState(
      items: items ?? this.items,
      prayerTimes: prayerTimes ?? this.prayerTimes,
    );
  }
}

class NotificationReminderStateNotifier
    extends BaseStateNotifier<NotificationReminderPageState> {
  NotificationReminderStateNotifier() : super(NotificationReminderPageState());

  @override
  initStateNotifier() async {
    // TODO: implement initStateNotifier
    _getPrayerData();
  }

  Future<void> _getPrayerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('latitude') && prefs.containsKey('longitude')) {
      final params = await getPrayerParams();
      Coordinates _myCoordinates = await getSavedCoordinates();
      PrayerTimes _prayerTimes = PrayerTimes.today(_myCoordinates, params);

      List<PrayerModel> _list = <PrayerModel>[];
      _list.add(PrayerModel(
        index: Prayer.fajr.index,
        image: IconPath.iconFajr,
        prayerNames: prayerNames[Prayer.fajr.index],
        prayerTime: _prayerTimes.timeForPrayer(Prayer.fajr)!,
        alarm: await getAlarmFlag(Prayer.fajr.index),
      ));
      _list.add(PrayerModel(
        index: Prayer.dhuhr.index,
        image: IconPath.iconDhuhr,
        prayerNames: prayerNames[Prayer.dhuhr.index],
        prayerTime: _prayerTimes.timeForPrayer(Prayer.dhuhr)!,
        alarm: await getAlarmFlag(Prayer.dhuhr.index),
      ));
      _list.add(PrayerModel(
        index: Prayer.asr.index,
        image: IconPath.iconAshr,
        prayerNames: prayerNames[Prayer.asr.index],
        prayerTime: _prayerTimes.timeForPrayer(Prayer.asr)!,
        alarm: await getAlarmFlag(Prayer.asr.index),
      ));
      _list.add(PrayerModel(
        index: Prayer.maghrib.index,
        image: IconPath.iconMaghrib,
        prayerNames: prayerNames[Prayer.maghrib.index],
        prayerTime: _prayerTimes.timeForPrayer(Prayer.maghrib)!,
        alarm: await getAlarmFlag(Prayer.maghrib.index),
      ));
      _list.add(PrayerModel(
        index: Prayer.isha.index,
        image: IconPath.iconIsha,
        prayerNames: prayerNames[Prayer.isha.index],
        prayerTime: _prayerTimes.timeForPrayer(Prayer.isha)!,
        alarm: await getAlarmFlag(Prayer.isha.index),
      ));

      state = state.copyWith(prayerTimes: _prayerTimes, items: _list);
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    return formattedTime;
  }

  Future<void> onAlarmPressed(
    bool alarmFlag,
    int index,
    DateTime prayerTime,
  ) async {
    setAlarmNotification(state.prayerTimes!, index, alarmFlag);
    saveAlarmFlag(index, alarmFlag);
    _getPrayerData();
  }
}
