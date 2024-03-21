import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';

final StateProvider<AdzanState> adzanCardProvider =
    StateProvider<AdzanState>((ref) {
  final PrayerTimeState prayerTimeState = ref.watch(prayerTimeProvider);

  final DateTime now = DateTime.now();

  if (prayerTimeState.prayerTimes == null) {
    return const AdzanState(null, null);
  }

  if (prayerTimeState.prayerTimes!.isha.compareTo(now) > 0 ||
      prayerTimeState.prayerTimes!.fajr.compareTo(now) < 0) {
    return AdzanState(
      PrayerTimesList.fajr,
      prayerTimeState.prayerTimes!.fajr,
    );
  }

  if (prayerTimeState.prayerTimes!.isha.compareTo(now) < 0 &&
      prayerTimeState.prayerTimes!.maghrib.compareTo(now) > 0) {
    return AdzanState(
      PrayerTimesList.isya,
      prayerTimeState.prayerTimes!.isha,
    );
  }

  if (prayerTimeState.prayerTimes!.maghrib.compareTo(now) < 0 &&
      prayerTimeState.prayerTimes!.asr.compareTo(now) > 0) {
    return AdzanState(
      PrayerTimesList.magrib,
      prayerTimeState.prayerTimes!.maghrib,
    );
  }

  if (prayerTimeState.prayerTimes!.asr.compareTo(now) < 0 &&
      prayerTimeState.prayerTimes!.dhuhr.compareTo(now) > 0) {
    return AdzanState(
      PrayerTimesList.ashr,
      prayerTimeState.prayerTimes!.asr,
    );
  }

  return AdzanState(
    PrayerTimesList.dhuhr,
    prayerTimeState.prayerTimes!.dhuhr,
  );
});

class AdzanState {
  final PrayerTimesList? prayerTimesList;
  final DateTime? date;

  const AdzanState(this.prayerTimesList, this.date);
}
