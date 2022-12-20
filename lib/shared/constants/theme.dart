import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

double defaultMargin = 24.0;

// Color
const Color primary100 = Color(0xFFF4F8EC);
const Color primary200 = Color(0xFFE9F2DA);
const Color primary300 = Color(0xFFCCD9B9);
const Color primary400 = Color(0xFFA4B493);
const Color primary500 = Color(0xFF728363);
const Color primary600 = Color(0xFF597048);
const Color primary700 = Color(0xFF425E31);
const Color primary800 = Color(0xFF2D4B1F);
const Color primary900 = Color(0xFF1E3E13);

const Color neutral100 = Color(0xFFF5F5F5);
const Color neutral200 = Color(0xFFEEEEEE);
const Color neutral300 = Color(0xFFE0E0E0);
const Color neutral400 = Color(0xFFBDBDBD);
const Color neutral500 = Color(0xFF9E9E9E);
const Color neutral600 = Color(0xFF757575);
const Color neutral700 = Color(0xFF616161);
const Color neutral800 = Color(0xFF424242);
const Color neutral900 = Color(0xFF212121);

const Color exit100 = Color(0xFFFBDED4);
const Color exit200 = Color(0xFFF8B7AA);
const Color exit300 = Color(0xFFEC847D);
const Color exit400 = Color(0xFFD9595D);
const Color exit500 = Color(0xFFC12A3C);
const Color exit600 = Color(0xFFA51E3B);
const Color exit700 = Color(0xFF8A1538);
const Color exit800 = Color(0xFF6F0D34);
const Color exit900 = Color(0xFF5C0831);

const Color errorColor = Color(0xFFFF6D7E);

const Color red300 = Color(0xFFEC847D);

const Color backgroundColor = Color(0xFFF8F7F3);
const Color backgroundTextTafsir = Color(0xFFF0F0F0);

const Color darkGreen = Color(0xFF728363);
const Color secondaryGreen = Color(0xFF0E2009);
const Color secondaryGreen300 = Color(0xFFBAC6AA);
const Color yellowBorder = Color(0xFFFFC535);

const Color brokenWhite = Color(0xffF8F7F3);

FontWeight extraLight = FontWeight.w200;
FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semiBold = FontWeight.w600;
FontWeight bold = FontWeight.w700;

// Typography
TextStyle suratFontStyle = const TextStyle(
  fontFamily: 'UthmanThaha',
  fontSize: 24,
);

TextStyle ayatFontStyle =
    const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 24);

TextStyle headingBold1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 24, fontWeight: bold);

TextStyle headingMedium1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 24, fontWeight: medium);

TextStyle headingRegular1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 24, fontWeight: regular);

TextStyle subHeadingSemiBold1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 20, fontWeight: semiBold);

TextStyle subHeadingMedium1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 20, fontWeight: medium);

TextStyle subHeadingRegular1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 20, fontWeight: regular);

TextStyle subHeadingSemiBold2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 16, fontWeight: semiBold);

TextStyle subHeadingMedium2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 16, fontWeight: medium);

TextStyle subHeadingRegular2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 16, fontWeight: regular);

TextStyle bodyMedium1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 16, fontWeight: medium);

TextStyle bodyRegular1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 16, fontWeight: regular);

TextStyle bodyLight1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 16, fontWeight: light);

TextStyle bodySemibold2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 14, fontWeight: semiBold);

TextStyle bodyMedium2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 14, fontWeight: medium);

TextStyle bodyRegular2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 14, fontWeight: regular);

TextStyle bodyLight2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 14, fontWeight: light);

TextStyle bodyMedium3 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 12, fontWeight: medium);

TextStyle bodyRegular3 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 12, fontWeight: regular);

TextStyle bodyLight3 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 12, fontWeight: light);

TextStyle buttonRegular1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 14, fontWeight: regular);

TextStyle buttonSemiBold1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 14, fontWeight: semiBold);

TextStyle buttonMedium1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 14, fontWeight: medium);

TextStyle buttonSemiBold2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 12, fontWeight: semiBold);

TextStyle buttonMedium2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 12, fontWeight: medium);

TextStyle buttonMedium3 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 10, fontWeight: medium);

TextStyle caption1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 12, fontWeight: regular);

TextStyle captionSemiBold1 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 12, fontWeight: semiBold);

TextStyle captionRegular2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 10, fontWeight: regular);

TextStyle captionLight2 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 10, fontWeight: light);

TextStyle numberStyle =
    GoogleFonts.poppins(color: neutral900, fontSize: 12, fontWeight: medium);

TextStyle titleDrawerBold =
    GoogleFonts.poppins(color: darkGreen, fontSize: 14, fontWeight: bold);

TextStyle bodyDrawerRegular = GoogleFonts.poppins(
  color: secondaryGreen,
  fontSize: 14,
  fontWeight: regular,
);

TextStyle bodyLatin1 =
    GoogleFonts.notoSans(color: neutral600, fontSize: 12, fontWeight: regular);

TextStyle regular10 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 10, fontWeight: regular);

TextStyle regular8 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 8, fontWeight: regular);

TextStyle semiBold10 =
    GoogleFonts.notoSans(color: neutral900, fontSize: 10, fontWeight: semiBold);

TextStyle buildTextStyle({
  required Color color,
  required double fontSize,
  required FontWeight fontWeight,
}) {
  return GoogleFonts.notoSans(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}

BoxShadow shadowPrimary = BoxShadow(
  color: Colors.grey.withOpacity(0.5),
  spreadRadius: 5,
  blurRadius: 7,
  offset: const Offset(0, 3),
);

OutlineInputBorder enabledInputBorder = const OutlineInputBorder(
  borderSide: BorderSide(
    color: neutral500,
    width: 0.5,
  ),
  borderRadius: BorderRadius.all(Radius.circular(8.0)),
);

OutlineInputBorder errorInputBorder = const OutlineInputBorder(
  borderSide: BorderSide(
    color: errorColor,
    width: 1,
  ),
  borderRadius: BorderRadius.all(Radius.circular(8.0)),
);
