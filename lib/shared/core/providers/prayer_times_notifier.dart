import 'dart:io';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'prayer_times_notifier.g.dart';

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

@riverpod
class PrayerTimeNotifier extends _$PrayerTimeNotifier {
  late PrayerTimesService _prayerTimesService;

  @override
  PrayerTimeState build() {
    _prayerTimesService = ref.watch(prayerTimesService);
    final cityName = _prayerTimesService.getCityName();
    return PrayerTimeState(
      locationIsOn: false,
      isLoading: false,
      prayerTimes: _prayerTimesService.getTodayPrayerTimes(),
      cityName: cityName,
    );
  }

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
    await _prayerTimesService.setCoordinates(latitude, longitude, cityName);
    if (Platform.isIOS) {
      await _prayerTimesService.setupMultiDayPrayerTimesReminder();
    } else {
      await _prayerTimesService.setupPrayerTimesReminder();
    }
  }

  Future<void> updatePrayerTimes(
    String calculationMethod,
    String madhab,
  ) async {
    final updatedPrayerTimes = _prayerTimesService.getTodayPrayerTimes(
      calculationMethod: calculationMethod,
      madhab: madhab,
    );
    state = state.copyWith(prayerTimes: updatedPrayerTimes);

    if (Platform.isIOS) {
      await _prayerTimesService.setupMultiDayPrayerTimesReminder(
        calculationMethod: calculationMethod,
        madhab: madhab,
      );
    } else {
      await _prayerTimesService.setupPrayerTimesReminder(
        calculationMethod: calculationMethod,
        madhab: madhab,
      );
    }
  }

  void refresh() {
    final cityName = _prayerTimesService.getCityName();
    state = state.copyWith(
      isLoading: false,
      prayerTimes: _prayerTimesService.getTodayPrayerTimes(),
      cityName: cityName,
    );
  }
}
