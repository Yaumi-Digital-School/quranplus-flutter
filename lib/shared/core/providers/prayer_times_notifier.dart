import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';

class PrayerTimeState {
  PrayerTimeState({
    this.locationIsOn = false,
    this.isLoading = true,
    this.prayerTimes,
    this.cityName,
  });

  bool isLoading;
  bool locationIsOn;
  PrayerTimes? prayerTimes;
  String? cityName;

  PrayerTimeState copyWith({
    bool? isLoading,
    bool? locationIsOn,
    PrayerTimes? prayerTimes,
    String? cityName,
  }) {
    return PrayerTimeState(
      locationIsOn: locationIsOn ?? this.locationIsOn,
      isLoading: isLoading ?? this.isLoading,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      cityName: cityName ?? this.cityName,
    );
  }

  String getPrayerTimesFormatted(PrayerTimesList prayerTime) {
    if (prayerTimes == null) {
      return "__:__";
    }

    switch (prayerTime) {
      case PrayerTimesList.fajr:
        final fajrLocal = prayerTimes!.fajr.toLocal();
        return '${formatTwoDigits(fajrLocal.hour)}:${formatTwoDigits(fajrLocal.minute)}';
      case PrayerTimesList.dhuhr:
        final dhuhrLocal = prayerTimes!.dhuhr.toLocal();
        return '${formatTwoDigits(dhuhrLocal.hour)}:${formatTwoDigits(dhuhrLocal.minute)}';
      case PrayerTimesList.ashr:
        final asrLocal = prayerTimes!.asr.toLocal();
        return '${formatTwoDigits(asrLocal.hour)}:${formatTwoDigits(asrLocal.minute)}';
      case PrayerTimesList.magrib:
        final maghribLocal = prayerTimes!.maghrib.toLocal();
        return '${formatTwoDigits(maghribLocal.hour)}:${formatTwoDigits(maghribLocal.minute)}';
      case PrayerTimesList.isya:
        final ishaLocal = prayerTimes!.isha.toLocal();
        return '${formatTwoDigits(ishaLocal.hour)}:${formatTwoDigits(ishaLocal.minute)}';
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

  Future<void> changeLocation(
    double latitude,
    double longitude,
    String cityName,
  ) async {
    await prayerTimesService.setCoordinates(latitude, longitude, cityName);
    await prayerTimesService.setupPrayerTimesReminder();
  }

  @override
  Future<void> initStateNotifier() async {
    final updatedCityName = prayerTimesService.getCityName();
    state = state.copyWith(
      isLoading: false,
      prayerTimes: prayerTimesService.getTodayPrayerTimes(),
      cityName: updatedCityName,
    );
  }
}

final prayerTimeProvider =
    StateNotifierProvider<PrayerTimeStateNotifier, PrayerTimeState>((ref) {
  return PrayerTimeStateNotifier(ref.watch(prayerTimesService));
});
