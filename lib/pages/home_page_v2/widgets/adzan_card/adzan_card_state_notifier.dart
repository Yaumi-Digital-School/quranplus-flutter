import 'package:adhan_dart/adhan_dart.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'adzan_card_state_notifier.g.dart';

class AdzanState {
  final PrayerTimesList? prayerTimesList;
  final DateTime? date;
  final String? cityName;

  const AdzanState(this.prayerTimesList, this.date, this.cityName);
}

/// Resolves the next upcoming prayer to display, cascading through [today]'s
/// times in order. After Isya has passed, it points at TOMORROW's Fajr (Bug B:
/// the old code showed today's already-passed Fajr). Pure — the unit-test seam.
AdzanState resolveAdzanState({
  required PrayerTimes? today,
  required PrayerTimes? tomorrow,
  required DateTime now,
  String? cityName,
}) {
  if (today == null) {
    return AdzanState(null, null, cityName);
  }

  if (now.isBefore(today.fajr.toLocal())) {
    return AdzanState(PrayerTimesList.fajr, today.fajr.toLocal(), cityName);
  }

  if (now.isBefore(today.dhuhr.toLocal())) {
    return AdzanState(PrayerTimesList.dhuhr, today.dhuhr.toLocal(), cityName);
  }

  if (now.isBefore(today.asr.toLocal())) {
    return AdzanState(PrayerTimesList.ashr, today.asr.toLocal(), cityName);
  }

  if (now.isBefore(today.maghrib.toLocal())) {
    return AdzanState(
      PrayerTimesList.magrib,
      today.maghrib.toLocal(),
      cityName,
    );
  }

  if (now.isBefore(today.isha.toLocal())) {
    return AdzanState(PrayerTimesList.isya, today.isha.toLocal(), cityName);
  }

  // After Isya: show tomorrow's Fajr (fall back to today's if unavailable).
  final DateTime nextFajr = (tomorrow ?? today).fajr.toLocal();
  return AdzanState(PrayerTimesList.fajr, nextFajr, cityName);
}

@riverpod
AdzanState adzanCard(Ref ref) {
  final PrayerTimeState prayerTimeState = ref.watch(prayerTimeProvider);
  final PrayerTimesService service = ref.watch(prayerTimesService);
  final DateTime now = DateTime.now();

  final PrayerTimes? tomorrow = service.getPrayerTimesByDate(
    date: now.add(const Duration(days: 1)),
  );

  return resolveAdzanState(
    today: prayerTimeState.prayerTimes,
    tomorrow: tomorrow,
    now: now,
    cityName: prayerTimeState.cityName,
  );
}
