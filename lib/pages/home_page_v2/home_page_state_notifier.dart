import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class HomePageState {
  HomePageState({
    this.name = '',
  });

  String name;

  HomePageState copyWith({
    String? name,
  }) {
    return HomePageState(
      name: name ?? this.name,
    );
  }
}

class HomePageStateNotifier extends BaseStateNotifier<HomePageState> {
  HomePageStateNotifier({
    required SharedPreferenceService sharedPreferenceService,
  })  : _sharedPreferenceService = sharedPreferenceService,
        super(HomePageState());

  final SharedPreferenceService _sharedPreferenceService;

  @override
  Future<void> initStateNotifier() async {
    getUsername();
  }

  void getUsername() async {
    var name = await _sharedPreferenceService.getUsername();
    state = state.copyWith(name: name);
  }
}
