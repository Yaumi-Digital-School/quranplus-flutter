import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qurantafsir_flutter/pages/notification_settings_page/notification_settings_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';

class AdhanNotificationCard extends ConsumerWidget {
  const AdhanNotificationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerTimeProvider);
    final adhanEnabled = ref.watch(
      notificationSettingsPageProvider.select((s) => s.adhanEnabled),
    );
    final notifier = ref.read(notificationSettingsPageProvider.notifier);

    final bool hasLocation = prayerState.prayerTimes != null;
    final formatter = PrayerTimeState(prayerTimes: prayerState.prayerTimes);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Adhan Notification',
              style: QPTextStyle.getSubHeading2SemiBold(context),
            ),
          ),
          if (prayerState.isLoading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 24),
          ] else if (!hasLocation) ...[
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Text(
                    "Can't show prayer times, because no location set.",
                    style: QPTextStyle.getSubHeading4Regular(context).copyWith(
                      color: QPColors.getColorBasedTheme(
                        dark: QPColors.whiteFair,
                        light: QPColors.blackSoft,
                        brown: QPColors.brownModeMassive,
                        context: context,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      RoutePaths.routeLocationManualPage,
                    ),
                    child: Text(
                      'set location',
                      style: QPTextStyle.getSubHeading4SemiBold(context)
                          .copyWith(
                            decoration: TextDecoration.underline,
                            color: QPColors.getColorBasedTheme(
                              dark: QPColors.whiteFair,
                              light: QPColors.blackMassive,
                              brown: QPColors.brownModeMassive,
                              context: context,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final prayer in PrayerTimesList.values)
              _AdhanNotificationRow(
                prayer: prayer,
                time: formatter.getPrayerTimesFormatted(prayer),
                enabled: false,
                onChanged: null,
              ),
          ] else ...[
            for (final prayer in PrayerTimesList.values)
              _AdhanNotificationRow(
                prayer: prayer,
                time: formatter.getPrayerTimesFormatted(prayer),
                enabled: adhanEnabled[prayer] ?? true,
                onChanged: (value) => notifier.toggleAdhan(prayer, value),
              ),
          ],
        ],
      ),
    );
  }
}

class _AdhanNotificationRow extends StatelessWidget {
  const _AdhanNotificationRow({
    required this.prayer,
    required this.time,
    required this.enabled,
    required this.onChanged,
  });

  final PrayerTimesList prayer;
  final String time;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SvgPicture.asset(
            prayer.icon.path,
            colorFilter: ColorFilter.mode(
              QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.brandHeavy,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
              BlendMode.srcIn,
            ),
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prayer.label,
              style: QPTextStyle.getBody2Medium(context).copyWith(
                color: QPColors.getColorBasedTheme(
                  dark: QPColors.whiteFair,
                  light: QPColors.brandHeavy,
                  brown: QPColors.brownModeMassive,
                  context: context,
                ),
              ),
            ),
          ),
          Text(
            time,
            style: QPTextStyle.getBody2Medium(context).copyWith(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.blackSoft,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            onChanged: onChanged,
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
