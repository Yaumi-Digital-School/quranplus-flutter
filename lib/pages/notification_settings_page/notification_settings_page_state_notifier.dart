import 'dart:io';

import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/prayer_times_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_settings_page_state_notifier.g.dart';

class NotificationSettingsPageState {
  const NotificationSettingsPageState({
    required this.adhanEnabled,
  });

  final Map<PrayerTimesList, bool> adhanEnabled;

  NotificationSettingsPageState copyWith({
    Map<PrayerTimesList, bool>? adhanEnabled,
  }) {
    return NotificationSettingsPageState(
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
    );
  }
}

@riverpod
class NotificationSettingsPageNotifier
    extends _$NotificationSettingsPageNotifier {
  late SharedPreferenceService _sharedPreferenceService;
  late PrayerTimesService _prayerTimesService;

  @override
  NotificationSettingsPageState build() {
    _sharedPreferenceService = ref.watch(sharedPreferenceServiceProvider);
    _prayerTimesService = ref.watch(prayerTimesService);

    final bool hasLocation =
        (_sharedPreferenceService.getCityName() ?? '').isNotEmpty;

    final Map<PrayerTimesList, bool> saved =
        _sharedPreferenceService.getAdhanEnabledMap() ??
        {for (final p in PrayerTimesList.values) p: hasLocation};

    if (_sharedPreferenceService.getAdhanEnabledMap() == null) {
      _sharedPreferenceService.setAdhanEnabledMap(saved);
    }

    return NotificationSettingsPageState(adhanEnabled: saved);
  }

  Future<void> toggleAdhan(PrayerTimesList prayer, bool value) async {
    final updated = Map<PrayerTimesList, bool>.from(state.adhanEnabled)
      ..[prayer] = value;

    state = state.copyWith(adhanEnabled: updated);
    await _sharedPreferenceService.setAdhanEnabledMap(updated);

    if (Platform.isIOS) {
      await _prayerTimesService.setupMultiDayPrayerTimesReminder(
        adhanEnabled: updated,
      );
    } else {
      await _prayerTimesService.setupPrayerTimesReminder(
        adhanEnabled: updated,
      );
    }
  }
}
