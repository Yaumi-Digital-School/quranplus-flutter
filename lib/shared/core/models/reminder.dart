import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Reminder {
  final String time;
  final RepeatInterval repeat;
  final String name;

  const Reminder({
    required this.time,
    required this.repeat,
    required this.name,
  });

  static Reminder? fromJson(dynamic json) {
    return json != null
        ? Reminder(
        time: json["time"],
        repeat: parseRepeatIntervalToValue(json["repeat"]),
        name: json["name"])
        : null;
  }

  dynamic toJson() {
    return {
      "time": time,
      "repeat": parseRepeatIntervalToString(repeat),
      "name": name,
    };
  }

  static String parseRepeatIntervalToString(RepeatInterval repeat) {
    switch (repeat) {
      case RepeatInterval.daily:
        return "Daily";
      case RepeatInterval.everyMinute:
        return "EveryMinute";
      case RepeatInterval.hourly:
        return "Hourly";
      case RepeatInterval.weekly:
        return "Weekly";
      default:
        return "Daily";
    }
  }

  static RepeatInterval parseRepeatIntervalToValue(String repeat) {
    switch (repeat) {
      case "Daily":
        return RepeatInterval.daily;
      case "EveryMinute":
        return RepeatInterval.everyMinute;
      case "Hourly":
        return RepeatInterval.hourly;
      case "Weekly":
        return RepeatInterval.weekly;
      default:
        return RepeatInterval.weekly;
    }
  }

}