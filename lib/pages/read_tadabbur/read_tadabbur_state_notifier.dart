import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'read_tadabbur_state_notifier.g.dart';

class ReadTadabburState {
  bool isLoading;
  bool isError;
  List<TadabburItemResponse> listTadabbur;

  ReadTadabburState({
    this.isError = false,
    this.isLoading = true,
    this.listTadabbur = const [],
  });

  ReadTadabburState copyWith({
    bool? isLoading,
    bool? isError,
    List<TadabburItemResponse>? listTadabbur,
  }) {
    return ReadTadabburState(
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      listTadabbur: listTadabbur ?? this.listTadabbur,
    );
  }
}

@riverpod
class ReadTadabburNotifier extends _$ReadTadabburNotifier {
  @override
  ReadTadabburState build(int surahId) {
    Future.microtask(() => _getListTadabbur(surahId));
    return ReadTadabburState();
  }

  Future<void> _getListTadabbur(int surahId) async {
    final api = ref.read(tadabburApiProvider);
    try {
      state = state.copyWith(isLoading: true, isError: false);
      final HttpResponse<List<TadabburItemResponse>> result =
          await api.getListTadabburOfSurah(surahId: surahId);
      state = state.copyWith(isLoading: false, listTadabbur: result.data);
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _getListTadabbur() method',
      );
      log(error.toString());
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}
