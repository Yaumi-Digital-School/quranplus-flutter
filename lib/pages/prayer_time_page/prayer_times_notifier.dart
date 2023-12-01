import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/prayer_times.dart';

class PrayerTimeState {
  PrayerTimeState({
    required this.locationIsOn,
    this.isLoading = true,
    required this.listPrayerTimes,
  });
  bool isLoading;
  final bool locationIsOn;
  final List<PrayerTimesItem> listPrayerTimes;

  PrayerTimeState copyWith({
    bool? isLoading,
    bool? locationIsOn,
    List<PrayerTimesItem>? listPrayerTimes,
  }) {
    return PrayerTimeState(
      locationIsOn: locationIsOn ?? this.locationIsOn,
      isLoading: isLoading ?? this.isLoading,
      listPrayerTimes: listPrayerTimes ?? this.listPrayerTimes,
    );
  }
}

class PrayerTimeStateNotifier extends StateNotifier<PrayerTimeState> {
  PrayerTimeStateNotifier(
    PrayerTimeState state,
  ) : super(state);

  Future<void> checkGpsServices() async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool _permissionCondition = false;
    bool _locationCondition = false;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
      } else if (permission == LocationPermission.deniedForever) {
      } else {
        _permissionCondition = true;
      }
    }
    _permissionCondition = true;

    if (_permissionCondition) {
      bool servicestatus = await Geolocator.isLocationServiceEnabled();

      if (servicestatus) {
        _locationCondition = true;
      }
    }

    state = state.copyWith(locationIsOn: _locationCondition);
  }

  Future<void> updateAutoDetectCondition(bool autoDetectCondition) async {
    state = state.copyWith(locationIsOn: autoDetectCondition);
  }

  Future<void> getPrayerTimes() async {
    try {
      state = state.copyWith(
          //listPrayerTimes: prayerTimeItems,
          );
      // if (json.isEmpty) {}
    } catch (e) {
      log(e.toString());
    }
  }
}

final prayerTimeProvider =
    StateNotifierProvider<PrayerTimeStateNotifier, PrayerTimeState>((ref) {
  return PrayerTimeStateNotifier(
    PrayerTimeState(
      listPrayerTimes: [],
      locationIsOn: false,
    ),
  );
});
