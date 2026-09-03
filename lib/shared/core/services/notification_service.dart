import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification ID for the ongoing "today's prayer times" notification.
/// Kept away from the scheduled-prayer IDs (0-34) and quran-reminder IDs
/// (100-124) so it can be posted/canceled independently.
const int persistentPrayerTimesNotifId = 900;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  /// Generative constructor used only by tests to create a recording fake
  /// (the public factory always returns the shared singleton, which cannot be
  /// subclassed). Never call this in production code.
  @visibleForTesting
  NotificationService.forTesting();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'channel_id', //String, //Required for Android 8.0 or after
        'channel_name', //Required for Android 8.0 or after
        channelDescription: 'description', //Required for Android 8.0 or after
        importance: Importance.high,
        priority: Priority.high,
      );

  static const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

  static const NotificationDetails platformNotificationDetails =
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        );
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    final tz.TZDateTime when = tz.TZDateTime.from(scheduledDateTime, tz.local);

    try {
      // Exact alarms fire at the scheduled minute even in Doze — required so
      // prayer-time reminders arrive on time rather than being batched/delayed.
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        when,
        platformNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException {
      // If exact-alarm permission is unavailable (e.g. revoked), fall back to
      // an inexact alarm so the reminder still fires — just less precisely.
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        when,
        platformNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformNotificationDetails,
    );
  }

  /// Posts (or updates) an ongoing, non-dismissable Android notification on a
  /// dedicated silent, low-importance channel. The multi-line [body] is shown
  /// expanded via [BigTextStyleInformation]. Android-only details; callers must
  /// guard the platform.
  Future<void> showOngoing({
    required int id,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'prayer_times_persistent',
          'Daily Prayer Times',
          channelDescription:
              "Shows today's prayer times in the notification bar",
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          playSound: false,
          enableVibration: false,
          showWhen: false,
          styleInformation: BigTextStyleInformation(body, contentTitle: title),
        );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+ (API 33) requires a runtime grant for POST_NOTIFICATIONS;
    // without it the OS silently drops every notification.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Whether the app can currently schedule exact alarms. On Android 13+ the
  /// SCHEDULE_EXACT_ALARM permission is off by default and the user must enable
  /// it under "Alarms & reminders". Returns true on platforms where it doesn't
  /// apply (iOS, older Android) so callers never block there.
  Future<bool> canScheduleExactAlarms() async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (android == null) return true;
    return await android.canScheduleExactNotifications() ?? true;
  }

  /// Sends the user to the system "Alarms & reminders" screen to grant the
  /// SCHEDULE_EXACT_ALARM permission (Android only; no-op elsewhere).
  Future<void> requestExactAlarmsPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  Future<void> cancel(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
