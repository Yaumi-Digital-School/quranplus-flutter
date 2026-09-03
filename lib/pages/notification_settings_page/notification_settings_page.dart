import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/widgets/adhan_notification_card.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/widgets/header_info_card.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/widgets/persistent_prayer_notif_card.dart';
import 'package:qurantafsir_flutter/widgets/general_app_bar.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
