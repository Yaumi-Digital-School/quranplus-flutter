import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

enum QPThemeMode {
  dark,
  light,
  brown,
}

final Map<QPThemeMode, String> themeModeToLabelMode = <QPThemeMode, String>{
  QPThemeMode.dark: 'Dark Mode',
  QPThemeMode.brown: 'Brown Mode',
  QPThemeMode.light: 'Light Mode',
};

final Map<QPThemeMode, String> themeModeToLabel = <QPThemeMode, String>{
  QPThemeMode.dark: 'Dark',
  QPThemeMode.brown: 'Brown',
  QPThemeMode.light: 'Light',
};

extension QPThemeModeExtension on QPThemeMode {
  String get labelMode => themeModeToLabelMode[this] ?? '';

  String get label => themeModeToLabel[this] ?? '';
}

class QPThemeData {
  static ThemeData get lightThemeData {
    return ThemeData(
      scaffoldBackgroundColor: QPColors.whiteFair,
      dialogBackgroundColor: QPColors.whiteFair,
      dividerColor: QPColors.whiteRoot,
      hintColor: QPColors.blackSoft,
      colorScheme: const ColorScheme.light().copyWith(
        primary: QPColors.blackHeavy,
        primaryContainer: QPColors.whiteMassive,
        secondaryContainer: QPColors.whiteHeavy,
        surface: QPColors.whiteSoft,
      ),
    );
  }

  static ThemeData get darkThemeData {
    return ThemeData(
      scaffoldBackgroundColor: QPColors.darkModeMassive,
      dialogBackgroundColor: QPColors.darkModeMassive,
      dividerColor: QPColors.darkModeFair,
      hintColor: QPColors.blackSoft,
      colorScheme: const ColorScheme.light().copyWith(
        primary: QPColors.whiteFair,
        primaryContainer: QPColors.darkModeHeavy,
        secondaryContainer: QPColors.darkModeFair,
        surface: QPColors.darkModeHeavy,
      ),
    );
  }

  static ThemeData get brownThemeData {
    return ThemeData(
      scaffoldBackgroundColor: QPColors.brownModeRoot,
      dialogBackgroundColor: QPColors.brownModeRoot,
      dividerColor: QPColors.brownModeFair,
      hintColor: QPColors.brownModeMassive,
      colorScheme: const ColorScheme.light().copyWith(
        primary: QPColors.brownModeMassive,
        primaryContainer: QPColors.brownModeFair,
        secondaryContainer: QPColors.brownModeRoot,
        surface: QPColors.brownModeSoft,
      ),
    );
  }

  static QPThemeMode getThemeModeBasedContext(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBackgroundColor = theme.scaffoldBackgroundColor;
    if (scaffoldBackgroundColor == QPColors.brownModeRoot) {
      return QPThemeMode.brown;
    }

    if (scaffoldBackgroundColor == QPColors.darkModeMassive) {
      return QPThemeMode.dark;
    }

    return QPThemeMode.light;
  }
}
