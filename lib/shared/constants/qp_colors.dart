import 'package:flutter/material.dart';

class QPColors {
  static const Color brandMassive = Color(0xFF1E3E13);
  static const Color brandHeavy = Color(0xFF425E31);
  static const Color brandFair = Color(0xFF728363);
  static const Color brandSoft = Color(0xFFE9F2DA);
  static const Color brandRoot = Color(0xFFF4F8EC);

  static const Color blackMassive = Color(0xFF212121);
  static const Color blackHeavy = Color(0xFF434343);
  static const Color blackFair = Color(0xFF626262);
  static const Color blackSoft = Color(0xFF9E9E9E);
  static const Color blackRoot = Color(0xFFF5F5F5);

  static const Color whiteMassive = Color(0xFFFFFFFF);
  static const Color whiteHeavy = Color(0xFFF9F9F9);
  static const Color whiteFair = Color(0xFFF8F7F3);
  static const Color whiteSoft = Color(0xFFF2F2F2);
  static const Color whiteRoot = Color(0xFFE0E0E0);

  static const Color errorMassive = Color(0xFF8A1538);
  static const Color errorHeavy = Color(0xFFA51E3B);
  static const Color errorFair = Color(0xFFC12A3C);
  static const Color errorSoft = Color(0xFFEC847D);
  static const Color errorRoot = Color(0xFFFBDED4);

  static const Color warningMassive = Color(0xFF9D7C00);
  static const Color warningHeavy = Color(0xFFC8A700);
  static const Color warningFair = Color(0xFFFFCC00);
  static const Color warningSoft = Color(0xFFF3D769);
  static const Color warningRoot = Color(0xFFEEDC97);

  static const Color infoMassive = Color(0xFF18459E);
  static const Color infoHeavy = Color(0xFF4568AD);
  static const Color infoFair = Color(0xFF617EB7);
  static const Color infoSoft = Color(0xFF728BBD);
  static const Color infoRoot = Color(0xFF94A6C9);

  static const Color successMassive = Color(0xFF18459E);
  static const Color successHeavy = Color(0xFF4568AD);
  static const Color successFair = Color(0xFF617EB7);
  static const Color successSoft = Color(0xFF728BBD);
  static const Color successRoot = Color(0xFF94A6C9);

  static const Color primaryGreen100 = Color(0xFFF4F8EC);
  static const Color primaryGreen200 = Color(0xFFE9F2DA);
  static const Color primaryGreen300 = Color(0xFFCCD9B9);
  static const Color primaryGreen400 = Color(0xFFA4B493);
  static const Color primaryGreen500 = Color(0xFF728363);
  static const Color primaryGreen600 = Color(0xFF597048);
  static const Color primaryGreen700 = Color(0xFF425E31);
  static const Color primaryGreen800 = Color(0xFF2D4B1F);
  static const Color primaryGreen900 = Color(0xFF1E3E13);

  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  static const Color exit100 = Color(0xFFFBDED4);
  static const Color exit200 = Color(0xFFF8B7AA);
  static const Color exit300 = Color(0xFFEC847D);
  static const Color exit400 = Color(0xFFD9595D);
  static const Color exit500 = Color(0xFFC12A3C);
  static const Color exit600 = Color(0xFFA51E3B);
  static const Color exit700 = Color(0xFF8A1538);
  static const Color exit800 = Color(0xFF6F0D34);
  static const Color exit900 = Color(0xFF5C0831);

  static const Color background = Color(0xFFF8F7F3);

  static const Color darkModeMassive = Color(0xff121212);
  static const Color darkModeFair = Color(0xff282828);
  static const Color darkModeHeavy = Color(0xff1D1D1D);

  static const Color brownModeRoot = Color(0xffECE1CB);
  static const Color brownModeFair = Color(0xffE4D0A6);
  static const Color brownModeMassive = Color(0xff5B4A30);
  static const Color brownModeSoft = Color(0xffEADCC1);
  static const Color brownModeHeavy = Color(0xffCDB687);

  static Color getColorBasedTheme({
    required Color dark,
    required Color light,
    required Color brown,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final scaffoldBackgroundColor = theme.scaffoldBackgroundColor;
    if (scaffoldBackgroundColor == QPColors.brownModeRoot) {
      return brown;
    }

    if (scaffoldBackgroundColor == QPColors.darkModeMassive) {
      return dark;
    }

    return light;
  }
}
