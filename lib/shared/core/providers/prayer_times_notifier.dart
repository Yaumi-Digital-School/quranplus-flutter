import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times_list.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';

class PrayerTimeState {
  PrayerTimeState({
    this.locationIsOn = false,
    this.isLoading = true,
    this.prayerTimes,
  });

  bool isLoading;
  bool locationIsOn;
  PrayerTimes? prayerTimes;

  PrayerTimeState copyWith({
    bool? isLoading,
    bool? locationIsOn,
    PrayerTimes? prayerTimes,
  }) {
    return PrayerTimeState(
      locationIsOn: locationIsOn ?? this.locationIsOn,
      isLoading: isLoading ?? this.isLoading,
      prayerTimes: prayerTimes ?? this.prayerTimes,
    );
  }

  String getPrayerTimesFormatted(PrayerTimesList prayerTime) {
    if (prayerTimes == null) {
      return "__:__";
    }

    switch (prayerTime) {
      case PrayerTimesList.fajr:
        return '${formatTwoDigits(prayerTimes!.fajr.hour)}:${formatTwoDigits(prayerTimes!.fajr.minute)}';
      case PrayerTimesList.dhuhr:
        return '${formatTwoDigits(prayerTimes!.dhuhr.hour)}:${formatTwoDigits(prayerTimes!.dhuhr.minute)}';
      case PrayerTimesList.ashr:
        return '${formatTwoDigits(prayerTimes!.asr.hour)}:${formatTwoDigits(prayerTimes!.asr.minute)}';
      case PrayerTimesList.magrib:
        return '${formatTwoDigits(prayerTimes!.maghrib.hour)}:${formatTwoDigits(prayerTimes!.maghrib.minute)}';
      case PrayerTimesList.isya:
      default:
        return '${formatTwoDigits(prayerTimes!.isha.hour)}:${formatTwoDigits(prayerTimes!.isha.minute)}';
    }
  }
}

class PrayerTimeStateNotifier extends BaseStateNotifier<PrayerTimeState> {
  PrayerTimeStateNotifier(
    this.prayerTimesService,
  ) : super(PrayerTimeState(
          locationIsOn: false,
        ));

  final PrayerTimesService prayerTimesService;

  Future<void> checkGpsServices() async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool isPermissionGiven = false;
    bool locationCondition = false;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        isPermissionGiven = true;
      }
    }

    isPermissionGiven = true;

    if (isPermissionGiven) {
      bool servicestatus = await Geolocator.isLocationServiceEnabled();

      if (servicestatus) {
        locationCondition = true;
      }
    }

    state = state.copyWith(locationIsOn: locationCondition);
  }

  Future<void> updateAutoDetectCondition(bool autoDetectCondition) async {
    state = state.copyWith(locationIsOn: autoDetectCondition);
  }

  @override
  void initStateNotifier() {
    state = state.copyWith(
      isLoading: false,
      prayerTimes: prayerTimesService.getTodayPrayerTimes(),
    );
  }
}

final prayerTimeProvider =
    StateNotifierProvider<PrayerTimeStateNotifier, PrayerTimeState>((ref) {
  return PrayerTimeStateNotifier(
    ref.read(prayerTimesService),
  );
});
