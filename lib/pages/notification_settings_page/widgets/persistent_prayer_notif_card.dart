import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/notification_settings_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

/// Toggle for the ongoing "today's prayer times" notification. Android-only:
/// renders nothing on other platforms (there is no persistent-notification
/// concept on iOS).
class PersistentPrayerNotifCard extends ConsumerWidget {
  const PersistentPrayerNotifCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    final bool enabled = ref.watch(
      notificationSettingsPageProvider.select(
        (s) => s.persistentPrayerNotifEnabled,
      ),
    );
    final notifier = ref.read(notificationSettingsPageProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sticky prayer times notification',
                  style: QPTextStyle.getSubHeading4SemiBold(context).copyWith(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteFair,
                      light: QPColors.brandHeavy,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Keep today's prayer times pinned in your notification bar",
                  style: QPTextStyle.getSubHeading4Regular(context).copyWith(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteFair,
                      light: QPColors.blackSoft,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            onChanged: (value) => notifier.togglePersistentPrayerNotif(value),
            activeTrackColor: QPColors.brandHeavy,
            inactiveThumbColor: QPColors.getColorBasedTheme(
              dark: QPColors.blackHeavy,
              light: QPColors.whiteMassive,
              brown: QPColors.whiteMassive,
              context: context,
            ),
            inactiveTrackColor: QPColors.whiteSoft,
          ),
        ],
      ),
    );
  }
}
