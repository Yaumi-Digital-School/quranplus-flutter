// Unit tests for the home-screen widget payload builder (the pure seam of
// lib/shared/utils/prayer_times_widget.dart). The native provider renders
// exactly these keys, so the contract asserted here is what the widget shows.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/utils/prayer_times_widget.dart';

void main() {
  final DateTime date = DateTime(2026, 9, 12);
  final RegExp timeRegex = RegExp(r'^\d{2}:\d{2}$');

  PrayerTimes makeJakartaPrayerTimes() {
    return PrayerTimes(
      coordinates: const Coordinates(-6.2, 106.8),
      date: anchorDateForPrayerCalc(date),
      calculationParameters: CalculationMethodParameters.singapore(),
    );
  }

  group('buildPrayerTimesWidgetPayload', () {
    test('with prayer times: has_data + date + city + five HH:mm times', () {
      final Map<String, String> payload = buildPrayerTimesWidgetPayload(
        prayerTimes: makeJakartaPrayerTimes(),
        cityName: 'Jakarta',
        date: date,
      );

      expect(payload[widgetKeyHasData], 'true');
      expect(payload[widgetKeyDate], 'Saturday, 12 Sep 2026');
      expect(payload[widgetKeyCity], 'Jakarta');
      for (final String key in widgetPrayerTimeKeys) {
        expect(payload[key], matches(timeRegex), reason: 'missing $key');
      }
    });

    test('fajr comes before isha within the same local day', () {
      final Map<String, String> payload = buildPrayerTimesWidgetPayload(
        prayerTimes: makeJakartaPrayerTimes(),
        cityName: 'Jakarta',
        date: date,
      );

      final String fajr = payload[widgetPrayerTimeKeys.first]!;
      final String isya = payload[widgetPrayerTimeKeys.last]!;
      expect(fajr.compareTo(isya), lessThan(0));
    });

    test('no location (null prayer times): empty-state payload, no times', () {
      final Map<String, String> payload = buildPrayerTimesWidgetPayload(
        prayerTimes: null,
        cityName: null,
        date: date,
      );

      expect(payload[widgetKeyHasData], 'false');
      expect(payload[widgetKeyDate], 'Saturday, 12 Sep 2026');
      expect(payload[widgetKeyCity], '');
      for (final String key in widgetPrayerTimeKeys) {
        expect(payload.containsKey(key), isFalse, reason: '$key must be absent');
      }
    });
  });
}
