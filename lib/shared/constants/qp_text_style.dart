import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

class QPTextStyle {
  static TextStyle baseTextStyle =
      GoogleFonts.notoSans(color: QPColors.blackMassive);

  static TextStyle heading1Bold =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.bold, fontSize: 24);
  static TextStyle heading1SemiBold =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 24);
  static TextStyle heading1Regular =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.regular, fontSize: 24);

  static TextStyle subHeading1Medium =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.medium, fontSize: 20);
  static TextStyle subHeading1SemiBold =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 20);
  static TextStyle subHeading1Regular =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.regular, fontSize: 20);

  static TextStyle subHeading2Medium =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.medium, fontSize: 16);
  static TextStyle subHeading2SemiBold =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 16);
  static TextStyle subHeading2Regular =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.regular, fontSize: 16);

  static TextStyle subHeading3Medium =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.medium, fontSize: 14);
  static TextStyle subHeading3SemiBold =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 14);
  static TextStyle subHeading3Regular =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.regular, fontSize: 14);

  static TextStyle subHeading4Medium =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.medium, fontSize: 12);
  static TextStyle subHeading4SemiBold =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 12);
  static TextStyle subHeading4Regular =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.regular, fontSize: 12);

  static TextStyle body1Medium = subHeading2Medium;
  static TextStyle body1SemiBold = subHeading2SemiBold;
  static TextStyle body1Regular = subHeading2Regular;

  static TextStyle body2Medium = subHeading3Medium;
  static TextStyle body2SemiBold = subHeading3SemiBold;
  static TextStyle body2Regular = subHeading3Regular;

  static TextStyle body3Medium = subHeading4Medium;
  static TextStyle body3SemiBold = subHeading4SemiBold;
  static TextStyle body3Regular = subHeading4Regular;

  static TextStyle button1SemiBold = subHeading3SemiBold;
  static TextStyle button1Medium = subHeading3Medium;

  static TextStyle button2SemiBold = subHeading4SemiBold;
  static TextStyle button2Medium = subHeading4Medium;

  static TextStyle button3SemiBold =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 10);
  static TextStyle button3Medium =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.medium, fontSize: 10);

  static TextStyle description1Regular =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.regular, fontSize: 12);
  static TextStyle description2Regular =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.regular, fontSize: 10);

  static TextStyle caption =
      baseTextStyle.copyWith(fontWeight: QPFontWeight.light, fontSize: 10);
}

class QPFontWeight {
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
