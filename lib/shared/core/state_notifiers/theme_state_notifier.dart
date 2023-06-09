import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class ThemeStateNotifier extends BaseStateNotifier<QPThemeMode> {
  ThemeStateNotifier({required this.sharedPreferenceService})
      : super(QPThemeMode.light);

  final SharedPreferenceService sharedPreferenceService;

  @override
  initStateNotifier() {
    final currentMode = sharedPreferenceService.getTheme();
    state = QPThemeMode.values.byName(currentMode);
  }

  void setMode(QPThemeMode newMode) async {
    await sharedPreferenceService.setTheme(newMode.name);
    state = newMode;
  }
}
