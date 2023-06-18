import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/models/theme_option_color_param.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';

class ThemeStateNotifier extends BaseStateNotifier<QPThemeMode> {
  ThemeStateNotifier({required this.sharedPreferenceService})
      : super(QPThemeMode.light);

  final SharedPreferenceService sharedPreferenceService;

  @override
  initStateNotifier() {
    final currentMode = sharedPreferenceService.getTheme();
    state = currentMode != ""
        ? QPThemeMode.values.byName(currentMode)
        : QPThemeMode.light;
  }

  void setMode(QPThemeMode newMode) async {
    await sharedPreferenceService.setTheme(newMode.name);
    state = newMode;
  }

  ThemeOptionColorParam getThemeOptionColor() {
    switch (state) {
      case QPThemeMode.dark:
        return ThemeOptionColorParam(
          firstColor: QPColors.darkModeHeavy,
          secondColor: QPColors.blackFair,
          thirdColor: QPColors.darkModeFair,
        );
      case QPThemeMode.brown:
        return ThemeOptionColorParam(
          firstColor: QPColors.brownModeRoot,
          secondColor: QPColors.whiteMassive,
          thirdColor: QPColors.brownModeFair,
        );
      case QPThemeMode.light:
      default:
        return ThemeOptionColorParam(
          firstColor: QPColors.whiteSoft,
          secondColor: QPColors.whiteMassive,
          thirdColor: QPColors.whiteRoot,
        );
    }
  }
}
