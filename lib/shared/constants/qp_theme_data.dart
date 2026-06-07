import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_themed_colors.dart';

enum QPThemeMode { dark, light, brown }

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
      dividerColor: QPColors.whiteRoot,
      appBarTheme: const AppBarThemeData(
        backgroundColor: QPColors.whiteFair,
        surfaceTintColor: Colors.transparent,
      ),
      hintColor: QPColors.blackSoft,
      colorScheme: const ColorScheme.light().copyWith(
        primary: QPColors.blackHeavy,
        primaryContainer: QPColors.whiteMassive,
        secondaryContainer: QPColors.whiteHeavy,
        surface: QPColors.whiteSoft,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: QPColors.whiteFair),
      extensions: const <ThemeExtension<dynamic>>[QPThemedColors.light],
    );
  }

  static ThemeData get darkThemeData {
    return ThemeData(
      scaffoldBackgroundColor: QPColors.darkModeMassive,
      appBarTheme: const AppBarThemeData(
        backgroundColor: QPColors.darkModeMassive,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: QPColors.darkModeFair,
      hintColor: QPColors.blackSoft,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: QPColors.whiteFair,
        primaryContainer: QPColors.darkModeHeavy,
        secondaryContainer: QPColors.darkModeFair,
        surface: QPColors.darkModeHeavy,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: QPColors.darkModeMassive,
      ),
      extensions: const <ThemeExtension<dynamic>>[QPThemedColors.dark],
    );
  }

  static ThemeData get brownThemeData {
    return ThemeData(
      scaffoldBackgroundColor: QPColors.brownModeRoot,
      appBarTheme: const AppBarThemeData(
        backgroundColor: QPColors.brownModeRoot,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: QPColors.brownModeFair,
      hintColor: QPColors.brownModeMassive,
      colorScheme: const ColorScheme.light().copyWith(
        primary: QPColors.brownModeMassive,
        primaryContainer: QPColors.brownModeFair,
        secondaryContainer: QPColors.brownModeRoot,
        surface: QPColors.brownModeSoft,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: QPColors.brownModeRoot,
      ),
      extensions: const <ThemeExtension<dynamic>>[QPThemedColors.brown],
    );
  }
}
