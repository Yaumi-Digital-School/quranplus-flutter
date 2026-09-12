import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';

/// Keys shared with the native side: PrayerTimesWidgetProvider.kt reads these
/// from home_widget's SharedPreferences to render the home-screen widget.
/// Renaming one here requires the same rename in the Kotlin provider.
const String widgetKeyHasData = 'ptw_has_data';
const String widgetKeyDate = 'ptw_date';
const String widgetKeyCity = 'ptw_city';
const List<String> widgetPrayerTimeKeys = <String>[
  'ptw_fajr',
  'ptw_dhuhr',
  'ptw_ashr',
  'ptw_magrib',
  'ptw_isya',
];

const String _widgetProviderQualifiedName =
    'com.yaumi.qurantafsir.id.PrayerTimesWidgetProvider';

/// Builds the key/value payload the home-screen widget renders. Pure and
/// side-effect free — the unit-test seam for the widget content.
///
/// A null [prayerTimes] (no location set yet) produces the empty-state
/// payload: the widget then shows a prompt to open the app instead of times.
Map<String, String> buildPrayerTimesWidgetPayload({
  required PrayerTimes? prayerTimes,
  required String? cityName,
  required DateTime date,
}) {
  final Map<String, String> payload = <String, String>{
    widgetKeyHasData: prayerTimes == null ? 'false' : 'true',
    widgetKeyDate: DateFormat('EEEE, d MMM yyyy').format(date),
    widgetKeyCity: cityName ?? '',
  };

  if (prayerTimes == null) {
    return payload;
  }

  final List<DateTime> prayerTimeList = <DateTime>[
    prayerTimes.fajr,
    prayerTimes.dhuhr,
    prayerTimes.asr,
    prayerTimes.maghrib,
    prayerTimes.isha,
  ];

  for (int i = 0; i < prayerTimeList.length; i++) {
    final DateTime localTime = prayerTimeList[i].toLocal();
    payload[widgetPrayerTimeKeys[i]] =
        '${formatTwoDigits(localTime.hour)}:${formatTwoDigits(localTime.minute)}';
  }

  return payload;
}

/// Pushes today's prayer times to the Android home-screen widget and asks it
/// to re-render. Android-only no-op elsewhere. Safe to call from both the
/// foreground and the Workmanager background isolate.
///
/// Never throws: the widget is a best-effort surface and must not break the
/// notification-scheduling paths it piggybacks on.
Future<void> updatePrayerTimesHomeWidget({
  required PrayerTimesService prayerTimesService,
}) async {
  if (kIsWeb || !Platform.isAndroid) return;

  try {
    final Map<String, String> payload = buildPrayerTimesWidgetPayload(
      prayerTimes: prayerTimesService.getPrayerTimesByDate(),
      cityName: prayerTimesService.getCityName(),
      date: DateTime.now(),
    );

    for (final MapEntry<String, String> entry in payload.entries) {
      await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
    }

    await HomeWidget.updateWidget(
      qualifiedAndroidName: _widgetProviderQualifiedName,
    );
  } catch (e) {
    debugPrint('Failed to update prayer times widget: $e');
  }
}
