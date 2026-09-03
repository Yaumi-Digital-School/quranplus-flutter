// Tests for the home-page adzan card "next prayer" resolution and the prayer
// date-anchoring fix.
//
// resolveAdzanState is a pure cascade over a real adhan_dart PrayerTimes; the
// after-Isya branch must point at TOMORROW's Fajr (Bug B). anchorDateForPrayerCalc
// pins Bug A: a pre-dawn local time in a positive-offset zone must still resolve
// to the correct LOCAL calendar day.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/adzan_card/adzan_card_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';

PrayerTimes buildJakartaPrayerTimes(DateTime localDay) {
  final CalculationParameters params = CalculationMethodParameters.singapore();
  params.madhab = Madhab.shafi;

  // Mirror how PrayerTimesService builds it: anchor at local noon -> UTC.
  return PrayerTimes(
    coordinates: const Coordinates(-6.2, 106.8),
    date: anchorDateForPrayerCalc(localDay),
    calculationParameters: params,
  );
}

void main() {
  group('anchorDateForPrayerCalc (Bug A)', () {
    test(
      'pre-dawn local time still anchors to the same local calendar day',
      () {
        // 02:00 local on 2026-09-04. The naive `.toUtc()` would (in UTC+7) land
        // on 2026-09-03; anchoring at noon keeps it on the intended local day.
        final DateTime local = DateTime(2026, 9, 4, 2);
        final DateTime anchored = anchorDateForPrayerCalc(local);

        expect(anchored.isUtc, isTrue);

        final DateTime back = anchored.toLocal();
        expect(back.year, 2026);
        expect(back.month, 9);
        expect(back.day, 4);
        expect(back.hour, 12);
      },
    );

    test('is stable regardless of the local hour within the day', () {
      final DateTime early = anchorDateForPrayerCalc(DateTime(2026, 9, 4, 0));
      final DateTime late = anchorDateForPrayerCalc(DateTime(2026, 9, 4, 23));
      expect(early, late);
    });
  });

  group('resolveAdzanState', () {
    final DateTime today = DateTime(2026, 9, 4);
    final DateTime tomorrowDay = DateTime(2026, 9, 5);
    final PrayerTimes todayTimes = buildJakartaPrayerTimes(today);
    final PrayerTimes tomorrowTimes = buildJakartaPrayerTimes(tomorrowDay);

    test('null today -> empty state', () {
      final AdzanState state = resolveAdzanState(
        today: null,
        tomorrow: tomorrowTimes,
        now: DateTime(2026, 9, 4, 10),
        cityName: 'Jakarta',
      );

      expect(state.prayerTimesList, isNull);
      expect(state.date, isNull);
      expect(state.cityName, 'Jakarta');
    });

    test('before fajr -> today fajr', () {
      final DateTime now = todayTimes.fajr.toLocal().subtract(
        const Duration(minutes: 5),
      );
      final AdzanState state = resolveAdzanState(
        today: todayTimes,
        tomorrow: tomorrowTimes,
        now: now,
      );

      expect(state.prayerTimesList, PrayerTimesList.fajr);
      expect(state.date, todayTimes.fajr.toLocal());
    });

    test('between dhuhr and asr -> ashr', () {
      final DateTime now = todayTimes.dhuhr.toLocal().add(
        const Duration(minutes: 1),
      );
      final AdzanState state = resolveAdzanState(
        today: todayTimes,
        tomorrow: tomorrowTimes,
        now: now,
      );

      expect(state.prayerTimesList, PrayerTimesList.ashr);
      expect(state.date, todayTimes.asr.toLocal());
    });

    test('after isya -> TOMORROW fajr (Bug B)', () {
      final DateTime now = todayTimes.isha.toLocal().add(
        const Duration(minutes: 5),
      );
      final AdzanState state = resolveAdzanState(
        today: todayTimes,
        tomorrow: tomorrowTimes,
        now: now,
      );

      expect(state.prayerTimesList, PrayerTimesList.fajr);
      expect(state.date, tomorrowTimes.fajr.toLocal());
      // The returned date must be tomorrow's, not today's stale fajr.
      expect(state.date!.day, tomorrowDay.day);
      expect(state.date, isNot(todayTimes.fajr.toLocal()));
    });

    test('after isya with null tomorrow -> falls back to today fajr', () {
      final DateTime now = todayTimes.isha.toLocal().add(
        const Duration(minutes: 5),
      );
      final AdzanState state = resolveAdzanState(
        today: todayTimes,
        tomorrow: null,
        now: now,
      );

      expect(state.prayerTimesList, PrayerTimesList.fajr);
      expect(state.date, todayTimes.fajr.toLocal());
    });
  });
}
