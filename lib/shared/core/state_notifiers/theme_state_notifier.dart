import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/core/models/theme_option_color_param.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  late SharedPreferenceService _sharedPreferenceService;

  @override
  QPThemeMode build() {
    _sharedPreferenceService = ref.read(sharedPreferenceServiceProvider);
    final currentMode = _sharedPreferenceService.getTheme();
    return currentMode.isNotEmpty
        ? QPThemeMode.values.byName(currentMode)
        : QPThemeMode.light;
  }

  void setMode(QPThemeMode newMode) async {
    await _sharedPreferenceService.setTheme(newMode.name);
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
        return ThemeOptionColorParam(
          firstColor: QPColors.whiteSoft,
          secondColor: QPColors.whiteMassive,
          thirdColor: QPColors.whiteRoot,
        );
    }
  }
}
