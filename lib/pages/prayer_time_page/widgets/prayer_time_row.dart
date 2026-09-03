import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';

class PrayerTimeRow extends ConsumerWidget {
  const PrayerTimeRow({super.key, this.prayerTimes});

  /// When provided, the row renders these times directly (used for the Tomorrow
  /// card and the by-date bottom sheet). When null, it watches
  /// `prayerTimeProvider` for today's times (the original behavior).
  final PrayerTimes? prayerTimes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PrayerTimes? resolvedPrayerTimes =
        prayerTimes ??
        ref.watch(prayerTimeProvider.select((s) => s.prayerTimes));

    final formatter = PrayerTimeState(prayerTimes: resolvedPrayerTimes);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final PrayerTimesList prayerTime in PrayerTimesList.values)
          Center(
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.darkModeFair,
                      light: QPColors.brandRoot,
                      brown: QPColors.brownModeHeavy,
                      context: context,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    prayerTime.icon.path,
                    colorFilter: const ColorFilter.mode(
                      QPColors.brandHeavy,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  prayerTime.label,
                  style: QPTextStyle.baseTextStyle.copyWith(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteRoot,
                      light: QPColors.blackMassive,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.getPrayerTimesFormatted(prayerTime),
                  style: QPTextStyle.baseTextStyle.copyWith(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteRoot,
                      light: QPColors.blackMassive,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
