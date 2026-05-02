import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/tadabbur.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tadabbur_surah_list_view_state_notifier.g.dart';

class TadabburSurahListViewState {
  TadabburSurahListViewState({
    this.tadabburSurahList,
    this.isLoading = true,
  });

  final List<GetTadabburSurahListItemResponse>? tadabburSurahList;
  final bool isLoading;

  TadabburSurahListViewState copyWith({
    List<GetTadabburSurahListItemResponse>? tadabburSurahList,
    bool? isLoading,
  }) {
    return TadabburSurahListViewState(
      tadabburSurahList: tadabburSurahList ?? this.tadabburSurahList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class TadabburSurahListViewNotifier extends _$TadabburSurahListViewNotifier {
  @override
  TadabburSurahListViewState build() {
    Future.microtask(_getAvailableTadabburSurahList);
    return TadabburSurahListViewState();
  }

  Future<void> _getAvailableTadabburSurahList() async {
    final api = ref.read(tadabburApiProvider);
    try {
      HttpResponse<List<GetTadabburSurahListItemResponse>> request =
          await api.getAvailableTadabburSurahList();

      if ((request.response.statusCode ?? 400) == 200) {
        state = state.copyWith(
          tadabburSurahList: request.data,
          isLoading: false,
        );
        return;
      }

      state = state.copyWith(tadabburSurahList: [], isLoading: false);
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _getAvailableTadabburSurahList() method',
      );
      state = state.copyWith(tadabburSurahList: [], isLoading: false);
    }
  }
}
