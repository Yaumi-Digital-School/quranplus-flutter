// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

class DateFormatType {
  static const String yyyyMMddHHmm = "yyyy-MM-dd HH:mm";
  static const String ddMMyy = "dd/MM/yy";
  static const String ddMMyyyy = "dd/MM/yyyy";
  static const String yyyyMMdd = "yyyy-MM-dd";
  static const String MMyyyy = "MM yyyy";
  static const String ddMMyyyyHHmm = "dd/MM/yyyy, HH:mm";
  static const String ddMMMMyyyyHHmm = "dd MMMM yyyy HH:mm";
  static const String ddMMyyHHmm = "dd/MM/yy, HH:mm";
  static const String MMMM = "MMMM";
  static const String EEEEddMMMMyyyyHHmm = "EEEE, dd MMMM yyyy, HH:mm";
  static const String MMMMyyyy = "MMMM yyyy";
  static const String ddmmyyhhmmss = "ddMMyyhhmmss";
  static const String EEEEddMMMyyyy = "EEEE dd MMM yyyy";
}

class DateUtils {
  static DateTime stringToDate(String dateString, String format) {
    String localization = "en_US";

    return DateFormat(format, localization).parse(dateString);
  }

  static String formatISOTime(DateTime date) {
    var duration = date.timeZoneOffset;
    if (duration.isNegative) {
      return (date.toIso8601String() +
          "-${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    }

    return (date.toIso8601String() +
        "+${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
  }

  static DateTime mostRecentMonday(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));

  static DateTime mostRecentSunday(DateTime date) =>
      DateTime(date.year, date.month, date.day - date.weekday % 7);
}
