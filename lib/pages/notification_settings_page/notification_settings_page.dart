import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/widgets/adhan_notification_card.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/widgets/header_info_card.dart';
import 'package:qurantafsir_flutter/widgets/general_app_bar.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: GeneralAppBar(title: 'Notifications'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            HeaderInfoCard(),
            SizedBox(height: 16),
            AdhanNotificationCard(),
          ],
        ),
      ),
    );
  }
}
