import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/widgets/adhan_notification_card.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/widgets/header_info_card.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/widgets/persistent_prayer_notif_card.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/services/notification_service.dart';
import 'package:qurantafsir_flutter/widgets/general_app_bar.dart';
import 'package:qurantafsir_flutter/widgets/utils/general_dialog.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    // On Android 13+ exact alarms are off by default; without them prayer-time
    // notifications don't fire on time. Prompt the user to enable the toggle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePromptExactAlarmPermission();
    });
  }

  Future<void> _maybePromptExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    final NotificationService notificationService = NotificationService();
    final bool canSchedule = await notificationService.canScheduleExactAlarms();
    if (canSchedule || !mounted) return;

    await showQPGeneralDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ExactAlarmPermissionDialog(
          onOpenSettings: () async {
            Navigator.of(dialogContext).pop();
            await notificationService.requestExactAlarmsPermission();
          },
          onDismiss: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeneralAppBar(title: 'Notifications'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const HeaderInfoCard(),
            const SizedBox(height: 16),
            const AdhanNotificationCard(),
            if (Platform.isAndroid) ...<Widget>[
              const SizedBox(height: 16),
              const PersistentPrayerNotifCard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExactAlarmPermissionDialog extends StatelessWidget {
  const _ExactAlarmPermissionDialog({
    required this.onOpenSettings,
    required this.onDismiss,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final Color textColor = QPColors.getColorBasedTheme(
      dark: QPColors.whiteFair,
      light: QPColors.blackMassive,
      brown: QPColors.brownModeMassive,
      context: context,
    );

    return AlertDialog(
      title: Text(
        'Allow exact prayer alarms',
        style: QPTextStyle.getSubHeading4SemiBold(
          context,
        ).copyWith(color: textColor),
      ),
      content: Text(
        "To deliver adhan notifications exactly on time, Quran Plus needs the "
        "\"Alarms & reminders\" permission. Tap Open settings and turn it on.",
        style: QPTextStyle.getBody3Regular(context).copyWith(color: textColor),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onDismiss,
          child: Text(
            'Not now',
            style: QPTextStyle.getButton2Medium(
              context,
            ).copyWith(color: textColor),
          ),
        ),
        TextButton(
          onPressed: onOpenSettings,
          child: Text(
            'Open settings',
            style: QPTextStyle.getButton2Medium(
              context,
            ).copyWith(color: QPColors.brandHeavy),
          ),
        ),
      ],
    );
  }
}
