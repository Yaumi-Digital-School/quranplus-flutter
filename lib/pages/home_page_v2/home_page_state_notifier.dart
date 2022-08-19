import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class HomePageState {
  HomePageState({
    this.name = '',
    this.token = ''
  });

  String token;
  String name;

  HomePageState copyWith({
    String? token,
    String? name,
  }) {
    return HomePageState(
      token: token ?? this.token,
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
    var token = await _sharedPreferenceService.getApiToken();
    var name = '';
    if (token.isNotEmpty) {
      name = await _sharedPreferenceService.getUsername();
    }

    state = state.copyWith(token: token, name: name);
  }
}
