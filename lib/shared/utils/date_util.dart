// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
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

class DateCustomUtils {
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

  static DateTime firstDayOfTheWeek(DateTime date) => DateTime(
        date.year,
        date.month,
        date.day - (date.weekday - 1),
      );

  static DateTime lastDayOfTheWeek(DateTime date) => date.add(
        Duration(days: DateTime.daysPerWeek - date.weekday),
      );

  static String getFirstDayOfTheWeekFromToday() {
    final DateTime mostRecentMondayFromToday =
        firstDayOfTheWeek(DateTime.now());
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(mostRecentMondayFromToday);

    return formattedDate;
  }

  static String getLastDayOfTheWeekFromToday() {
    final DateTime mostRecentSundayFromToday = lastDayOfTheWeek(DateTime.now());
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(mostRecentSundayFromToday);

    return formattedDate;
  }

  static String getCurrentDateInString() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(now);

    return formattedDate;
  }

  static String getDateRangeFormatted(DateTime from) {
    final DateTime currentTime = DateTime.now();

    final Duration timeDiffInDay = DateUtils.dateOnly(currentTime).difference(
      DateUtils.dateOnly(from),
    );

    if (timeDiffInDay < const Duration(days: 1)) {
      return '${from.hour}:${from.minute.toString().padLeft(2, "0")}';
    }

    if (timeDiffInDay <= const Duration(days: 7)) {
      return '${timeDiffInDay.inDays} Days Ago';
    }

    return '${from.day}-${from.month}-${from.year}';
  }
}
