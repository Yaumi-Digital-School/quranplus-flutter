import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

enum QPThemeMode {
  dark,
  light,
  brown,
}

class QPThemeData {
  static ThemeData get lightThemeData {
    return ThemeData(
      scaffoldBackgroundColor: QPColors.whiteFair,
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
