import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';

@immutable
class QPThemedColors extends ThemeExtension<QPThemedColors> {
  const QPThemedColors({
    required this.mode,
    required this.brand100,
    required this.brand80,
    required this.brand60,
    required this.brand40,
    required this.brand20,
    required this.neutral100,
    required this.neutral80,
    required this.neutral60,
    required this.neutral40,
    required this.neutral20,
    required this.surface100,
    required this.surface80,
    required this.surface60,
    required this.surface40,
    required this.surface20,
  });

  final QPThemeMode mode;

  final Color brand100;
  final Color brand80;
  final Color brand60;
  final Color brand40;
  final Color brand20;

  final Color neutral100;
  final Color neutral80;
  final Color neutral60;
  final Color neutral40;
  final Color neutral20;

  final Color surface100;
  final Color surface80;
  final Color surface60;
  final Color surface40;
  final Color surface20;

  /// Returns [base], unless an override is provided for the current [mode].
  Color resolve(Color base, {Color? light, Color? dark, Color? brown}) {
    switch (mode) {
      case QPThemeMode.light:
        return light ?? base;
      case QPThemeMode.dark:
        return dark ?? base;
      case QPThemeMode.brown:
        return brown ?? base;
    }
  }

  static const QPThemedColors light = QPThemedColors(
    mode: QPThemeMode.light,
    brand100: QPColors.brandFair,
    brand80: QPColors.brandHeavy,
    brand60: QPColors.brandMassive,
    brand40: QPColors.brandSoft,
    brand20: QPColors.brandRoot,
    neutral100: QPColors.blackFair,
    neutral80: QPColors.blackHeavy,
    neutral60: QPColors.blackMassive,
    neutral40: QPColors.blackSoft,
    neutral20: QPColors.whiteRoot,
    surface100: QPColors.whiteFair,
    surface80: QPColors.whiteHeavy,
    surface60: QPColors.whiteMassive,
    surface40: QPColors.whiteSoft,
    surface20: QPColors.whiteRoot,
  );

  static const QPThemedColors dark = QPThemedColors(
    mode: QPThemeMode.dark,
    brand100: QPColors.whiteFair,
    brand80: QPColors.whiteRoot,
    brand60: QPColors.brandFair,
    brand40: QPColors.brandHeavy,
    brand20: QPColors.brandMassive,
    neutral100: QPColors.whiteFair,
    neutral80: QPColors.whiteRoot,
    neutral60: QPColors.whiteMassive,
    neutral40: QPColors.blackSoft,
    neutral20: QPColors.blackFair,
    surface100: QPColors.darkModeMassive,
    surface80: QPColors.darkModeHeavy,
    surface60: QPColors.darkModeHeavy,
    surface40: QPColors.darkModeFair,
    surface20: QPColors.darkModeFair,
  );

  static const QPThemedColors brown = QPThemedColors(
    mode: QPThemeMode.brown,
    brand100: QPColors.brownModeMassive,
    brand80: QPColors.brownModeHeavy,
    brand60: QPColors.brandHeavy,
    brand40: QPColors.brownModeSoft,
    brand20: QPColors.brownModeRoot,
    neutral100: QPColors.brownModeMassive,
    neutral80: QPColors.blackHeavy,
    neutral60: QPColors.blackMassive,
    neutral40: QPColors.blackSoft,
    neutral20: QPColors.brownModeHeavy,
    surface100: QPColors.brownModeRoot,
    surface80: QPColors.brownModeSoft,
    surface60: QPColors.brownModeFair,
    surface40: QPColors.brownModeFair,
    surface20: QPColors.brownModeHeavy,
  );

  @override
  QPThemedColors copyWith({
    QPThemeMode? mode,
    Color? brand100,
    Color? brand80,
    Color? brand60,
    Color? brand40,
    Color? brand20,
    Color? neutral100,
    Color? neutral80,
    Color? neutral60,
    Color? neutral40,
    Color? neutral20,
    Color? surface100,
    Color? surface80,
    Color? surface60,
    Color? surface40,
    Color? surface20,
  }) {
    return QPThemedColors(
      mode: mode ?? this.mode,
      brand100: brand100 ?? this.brand100,
      brand80: brand80 ?? this.brand80,
      brand60: brand60 ?? this.brand60,
      brand40: brand40 ?? this.brand40,
      brand20: brand20 ?? this.brand20,
      neutral100: neutral100 ?? this.neutral100,
      neutral80: neutral80 ?? this.neutral80,
      neutral60: neutral60 ?? this.neutral60,
      neutral40: neutral40 ?? this.neutral40,
      neutral20: neutral20 ?? this.neutral20,
      surface100: surface100 ?? this.surface100,
      surface80: surface80 ?? this.surface80,
      surface60: surface60 ?? this.surface60,
      surface40: surface40 ?? this.surface40,
      surface20: surface20 ?? this.surface20,
    );
  }

  @override
  QPThemedColors lerp(ThemeExtension<QPThemedColors>? other, double t) {
    if (other is! QPThemedColors) return this;
    return QPThemedColors(
      mode: t < 0.5 ? mode : other.mode,
      brand100: Color.lerp(brand100, other.brand100, t)!,
      brand80: Color.lerp(brand80, other.brand80, t)!,
      brand60: Color.lerp(brand60, other.brand60, t)!,
      brand40: Color.lerp(brand40, other.brand40, t)!,
      brand20: Color.lerp(brand20, other.brand20, t)!,
      neutral100: Color.lerp(neutral100, other.neutral100, t)!,
      neutral80: Color.lerp(neutral80, other.neutral80, t)!,
      neutral60: Color.lerp(neutral60, other.neutral60, t)!,
      neutral40: Color.lerp(neutral40, other.neutral40, t)!,
      neutral20: Color.lerp(neutral20, other.neutral20, t)!,
      surface100: Color.lerp(surface100, other.surface100, t)!,
      surface80: Color.lerp(surface80, other.surface80, t)!,
      surface60: Color.lerp(surface60, other.surface60, t)!,
      surface40: Color.lerp(surface40, other.surface40, t)!,
      surface20: Color.lerp(surface20, other.surface20, t)!,
    );
  }
}

extension QPThemedColorsContext on BuildContext {
  QPThemedColors get qpColors =>
      Theme.of(this).extension<QPThemedColors>() ?? QPThemedColors.light;

  QPThemeMode get qpThemeMode => qpColors.mode;
}
