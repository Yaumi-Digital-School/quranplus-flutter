import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';

final StateProvider<AdzanState> adzanCardProvider =
    StateProvider<AdzanState>((ref) {
  final PrayerTimeState prayerTimeState = ref.watch(prayerTimeProvider);
  final String? cityName = prayerTimeState.cityName;
  final DateTime now = DateTime.now();

  if (prayerTimeState.prayerTimes == null) {
    return AdzanState(null, null, cityName);
  }

  if (now.isBefore(prayerTimeState.prayerTimes!.fajr.toLocal())) {
    return AdzanState(
      PrayerTimesList.fajr,
      prayerTimeState.prayerTimes!.fajr.toLocal(),
      cityName,
    );
  }

  if (now.isBefore(prayerTimeState.prayerTimes!.dhuhr.toLocal())) {
    return AdzanState(
      PrayerTimesList.dhuhr,
      prayerTimeState.prayerTimes!.dhuhr.toLocal(),
      cityName,
    );
  }

  if (now.isBefore(prayerTimeState.prayerTimes!.asr.toLocal())) {
    return AdzanState(
      PrayerTimesList.ashr,
      prayerTimeState.prayerTimes!.asr.toLocal(),
      cityName,
    );
  }

  if (now.isBefore(prayerTimeState.prayerTimes!.maghrib.toLocal())) {
    return AdzanState(
      PrayerTimesList.magrib,
      prayerTimeState.prayerTimes!.maghrib.toLocal(),
      cityName,
    );
  }

  if (now.isBefore(prayerTimeState.prayerTimes!.isha.toLocal())) {
    return AdzanState(
      PrayerTimesList.isya,
      prayerTimeState.prayerTimes!.isha.toLocal(),
      cityName,
    );
  }

  return AdzanState(
    PrayerTimesList.fajr,
    prayerTimeState.prayerTimes!.fajr.toLocal(),
    cityName,
  );
});

class AdzanState {
  final PrayerTimesList? prayerTimesList;
  final DateTime? date;
  final String? cityName;

  const AdzanState(
    this.prayerTimesList,
    this.date,
    this.cityName,
  );
}
