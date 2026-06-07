import 'dart:async';
import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/utils/number_util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'prayer_times_notifier.g.dart';

const int updateLocationCooldownDurationSeconds = 30;

class PrayerTimeState {
  PrayerTimeState({
    this.locationIsOn = false,
    this.isLoading = true,
    this.prayerTimes,
    this.cityName,
    this.updateLocationCooldownSeconds = 0,
    this.isFetchingLocation = false,
  });

  bool isLoading;
  bool locationIsOn;
  PrayerTimes? prayerTimes;
  String? cityName;
  int updateLocationCooldownSeconds;
  bool isFetchingLocation;

  PrayerTimeState copyWith({
    bool? isLoading,
    bool? locationIsOn,
    PrayerTimes? prayerTimes,
    String? cityName,
    int? updateLocationCooldownSeconds,
    bool? isFetchingLocation,
  }) {
    return PrayerTimeState(
      locationIsOn: locationIsOn ?? this.locationIsOn,
      isLoading: isLoading ?? this.isLoading,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      cityName: cityName ?? this.cityName,
      updateLocationCooldownSeconds:
          updateLocationCooldownSeconds ?? this.updateLocationCooldownSeconds,
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
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
  Timer? _cooldownTimer;

  @override
  PrayerTimeState build() {
    _prayerTimesService = ref.watch(prayerTimesService);
    final cityName = _prayerTimesService.getCityName();
    final autoDetectEnabled = _prayerTimesService.getAutoDetectLocation();
    ref.onDispose(() {
      _cooldownTimer?.cancel();
      _cooldownTimer = null;
    });

    if (autoDetectEnabled) {
      Future.microtask(_silentLocationRefresh);
    }

    return PrayerTimeState(
      locationIsOn: autoDetectEnabled,
      isLoading: false,
      prayerTimes: _prayerTimesService.getPrayerTimesByDate(),
      cityName: cityName,
    );
  }

  Future<void> _silentLocationRefresh() async {
    final permission = await Geolocator.checkPermission();
    final hasPermission =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!hasPermission || !serviceEnabled) {
      await _prayerTimesService.setAutoDetectLocation(false);
      state = state.copyWith(locationIsOn: false);
      return;
    }

    try {
      final cached = await Geolocator.getLastKnownPosition();
      if (cached != null) await _applyPosition(cached);
    } catch (_) {}

    try {
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      await _applyPosition(fresh);
    } catch (_) {}
  }

  Future<void> _applyPosition(Position position) async {
    final label = await _resolveCityLabel(
      position.latitude,
      position.longitude,
    );
    await changeLocation(position.latitude, position.longitude, label);
    state = state.copyWith(
      prayerTimes: _prayerTimesService.getPrayerTimesByDate(),
      cityName: label,
    );
  }

  Future<bool> setAutoDetect(bool enabled) async {
    await _prayerTimesService.setAutoDetectLocation(enabled);

    if (!enabled) {
      state = state.copyWith(locationIsOn: false);
      return true;
    }

    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      await _prayerTimesService.setAutoDetectLocation(false);
      state = state.copyWith(locationIsOn: false);
      return false;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _prayerTimesService.setAutoDetectLocation(false);
      state = state.copyWith(locationIsOn: false);
      return false;
    }

    state = state.copyWith(locationIsOn: true);
    final fetched = await _fetchAndApplyCurrentLocation();
    if (!fetched) {
      await _prayerTimesService.setAutoDetectLocation(false);
      state = state.copyWith(locationIsOn: false);
      return false;
    }
    return true;
  }

  Future<bool> updateLocationFromGps() async {
    if (state.updateLocationCooldownSeconds > 0) return false;

    final fetched = await _fetchAndApplyCurrentLocation();
    if (fetched) _startUpdateLocationCooldown();
    return fetched;
  }

  Future<bool> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> _fetchAndApplyCurrentLocation() async {
    state = state.copyWith(isFetchingLocation: true);
    try {
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 20),
          ),
        );
      } on TimeoutException {
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) return false;
      await _applyPosition(position);
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isFetchingLocation: false);
    }
  }

  Future<String> _resolveCityLabel(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return 'Current Location';
      final p = placemarks.first;
      final city = (p.locality?.isNotEmpty ?? false)
          ? p.locality!
          : (p.subAdministrativeArea?.isNotEmpty ?? false)
          ? p.subAdministrativeArea!
          : (p.administrativeArea ?? '');
      final country = p.country ?? '';
      if (city.isEmpty && country.isEmpty) return 'Current Location';
      if (city.isEmpty) return country;
      if (country.isEmpty) return city;
      return '$city, $country';
    } catch (_) {
      return 'Current Location';
    }
  }

  void _startUpdateLocationCooldown() {
    _cooldownTimer?.cancel();
    state = state.copyWith(
      updateLocationCooldownSeconds: updateLocationCooldownDurationSeconds,
    );
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.updateLocationCooldownSeconds - 1;
      if (remaining <= 0) {
        timer.cancel();
        _cooldownTimer = null;
        state = state.copyWith(updateLocationCooldownSeconds: 0);
      } else {
        state = state.copyWith(updateLocationCooldownSeconds: remaining);
      }
    });
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
    final updatedPrayerTimes = _prayerTimesService.getPrayerTimesByDate(
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
      prayerTimes: _prayerTimesService.getPrayerTimesByDate(),
      cityName: cityName,
    );
  }
}
