import 'dart:async';

import 'package:qurantafsir_flutter/shared/core/apis/model/city.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_manual_state_notifier.g.dart';

class LocationManualState {
  final bool isLoading;
  final bool isQueryEmpty;
  final List<CityResponse> cities;

  const LocationManualState({
    this.isLoading = false,
    this.cities = const [],
    this.isQueryEmpty = true,
  });

  LocationManualState copyWith({
    bool? isLoading,
    List<CityResponse>? cities,
    bool? isQueryEmpty,
  }) {
    return LocationManualState(
      isLoading: isLoading ?? this.isLoading,
      cities: cities ?? this.cities,
      isQueryEmpty: isQueryEmpty ?? this.isQueryEmpty,
    );
  }
}

@riverpod
class LocationManualNotifier extends _$LocationManualNotifier {
  Timer? _debounce;

  @override
  LocationManualState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const LocationManualState();
  }

  void onChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      onSearch(query);
    });
  }

  void onSearch(String query) async {
    try {
      state = state.copyWith(isLoading: true, isQueryEmpty: query.isEmpty);
      if (query.isEmpty) {
        state = state.copyWith(cities: []);
      } else {
        final cityApi = ref.read(cityApiProvider);
        final response = await cityApi.getCities(keyword: query);
        state = state.copyWith(cities: response.data);
      }
    } on Exception {
      state = state.copyWith(cities: []);
    } finally {
      state = state.copyWith(isLoading: false, isQueryEmpty: query.isEmpty);
    }
  }

  Future<void> onSelectCity(
    String id,
    String cityName,
    void Function() onLocationUpdate,
  ) async {
    try {
      state = state.copyWith(isLoading: true);
      final cityApi = ref.read(cityApiProvider);
      final response = await cityApi.getCityDetail(id: id);
      if (response.data.position != null) {
        await ref
            .read(prayerTimeProvider.notifier)
            .changeLocation(
              response.data.position!.lat,
              response.data.position!.lng,
              cityName,
            );
        state = state.copyWith(cities: []);
        onLocationUpdate();
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
