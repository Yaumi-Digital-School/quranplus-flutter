import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

class QPTextStyle {
  static TextStyle getBaseTextStyle(BuildContext context) {
    return GoogleFonts.notoSans(color: Theme.of(context).colorScheme.primary);
  }

  static TextStyle baseTextStyle =
      GoogleFonts.notoSans(color: QPColors.blackMassive);

  static TextStyle getHeading1Bold(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.bold, fontSize: 24);

  static TextStyle getHeading1SemiBold(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 24);

  static TextStyle getHeading1Regular(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.regular, fontSize: 24);

  static TextStyle getSubHeading1Medium(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.medium, fontSize: 20);

  static TextStyle getSubHeading1SemiBold(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 20);

  static TextStyle getSubHeading1Regular(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.regular, fontSize: 20);

  static TextStyle getSubHeading2Medium(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.medium, fontSize: 16);

  static TextStyle getSubHeading2SemiBold(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 16);

  static TextStyle getSubHeading2Regular(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.regular, fontSize: 16);

  static TextStyle getSubHeading3Medium(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.medium, fontSize: 14);

  static TextStyle getSubHeading3SemiBold(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 14);

  static TextStyle getSubHeading3Regular(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.regular, fontSize: 14);

  static TextStyle getSubHeading4Medium(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.medium, fontSize: 12);

  static TextStyle getSubHeading4SemiBold(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 12);

  static TextStyle getSubHeading4Regular(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.regular, fontSize: 12);

  static TextStyle getBody1Medium(BuildContext context) =>
      getSubHeading2Medium(context);
  static TextStyle getBody1SemiBold(BuildContext context) =>
      getSubHeading2SemiBold(context);
  static TextStyle getBody1Regular(BuildContext context) =>
      getSubHeading2Regular(context);

  static TextStyle getBody2Medium(BuildContext context) =>
      getSubHeading3Medium(context);
  static TextStyle getBody2SemiBold(BuildContext context) =>
      getSubHeading3SemiBold(context);
  static TextStyle getBody2Regular(BuildContext context) =>
      getSubHeading3Regular(context);

  static TextStyle getBody3Medium(BuildContext context) =>
      getSubHeading4Medium(context);
  static TextStyle getBody3SemiBold(BuildContext context) =>
      getSubHeading4SemiBold(context);

  static TextStyle getBody3Regular(BuildContext context) =>
      getBaseTextStyle(context).copyWith(
        fontWeight: QPFontWeight.regular,
        fontSize: 12,
        height: 1.6,
      );

  static TextStyle getButton1SemiBold(BuildContext context) =>
      getSubHeading3SemiBold(context);
  static TextStyle getButton1Medium(BuildContext context) =>
      getSubHeading3Medium(context);

  static TextStyle getButton2SemiBold(BuildContext context) =>
      getSubHeading4SemiBold(context);
  static TextStyle getButton2Medium(BuildContext context) =>
      getSubHeading4Medium(context);

  static TextStyle getButton3SemiBold(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 10);
  static TextStyle getButton3Medium(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.medium, fontSize: 10);

  static TextStyle getDescription1Regular(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.regular, fontSize: 12);
  static TextStyle getDescription2Regular(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.regular, fontSize: 10);
  static TextStyle getDescription2Medium(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.medium, fontSize: 10);

  static TextStyle getCaption(BuildContext context) => getBaseTextStyle(context)
      .copyWith(fontWeight: QPFontWeight.light, fontSize: 10);

  static TextStyle getCaption1SemiBold(BuildContext context) =>
      getBaseTextStyle(context)
          .copyWith(fontWeight: QPFontWeight.semiBold, fontSize: 12);
}

class QPFontWeight {
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}
