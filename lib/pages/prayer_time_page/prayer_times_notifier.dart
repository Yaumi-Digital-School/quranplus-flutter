import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeState {
  PrayerTimeState({
    required this.locationIsOn,
    this.isLoading = true,
  });
  bool isLoading;
  final bool locationIsOn;

  PrayerTimeState copyWith({
    bool? isLoading,
    bool? locationIsOn,
  }) {
    return PrayerTimeState(
      locationIsOn: locationIsOn ?? this.locationIsOn,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PrayerTimeStateNotifier extends StateNotifier<PrayerTimeState> {
  PrayerTimeStateNotifier(
    PrayerTimeState state,
  ) : super(state);

  Future<void> checkGpsServices() async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool permissionCondition = false;
    bool locationCondition = false;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        permissionCondition = true;
      }
    }

    permissionCondition = true;

    if (permissionCondition) {
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
      locationIsOn: false,
    ),
  );
});
