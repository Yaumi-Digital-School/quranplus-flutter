import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/widgets/prayer_calculation_selector.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/widgets/prayer_method_info_card.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/widgets/prayer_time_row.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';

class PrayerTimePage extends ConsumerWidget {
  const PrayerTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityName = ref.watch(prayerTimeProvider.select((s) => s.cityName));
    final locationIsOn = ref.watch(
      prayerTimeProvider.select((s) => s.locationIsOn),
    );
    final cooldownSeconds = ref.watch(
      prayerTimeProvider.select((s) => s.updateLocationCooldownSeconds),
    );
    final isFetchingLocation = ref.watch(
      prayerTimeProvider.select((s) => s.isFetchingLocation),
    );
    final notifier = ref.read(prayerTimeProvider.notifier);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.blackMassive,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Prayer Times",
            style: QPTextStyle.getSubHeading2SemiBold(context),
          ),
          automaticallyImplyLeading: false,
          elevation: 0.7,
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Prayer Times",
                                style: QPTextStyle.getSubHeading2SemiBold(
                                  context,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  color: QPColors.getColorBasedTheme(
                                    dark: QPColors.darkModeFair,
                                    light: QPColors.brandRoot,
                                    brown: QPColors.brownModeHeavy,
                                    context: context,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                    horizontal: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: QPColors.getColorBasedTheme(
                                          dark: QPColors.whiteFair,
                                          light: QPColors.brandFair,
                                          brown: QPColors.brownModeMassive,
                                          context: context,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          cityName ?? "",
                                          style: QPTextStyle.getBaseTextStyle(
                                            context,
                                          ).copyWith(fontSize: 10),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 90,
                          width: 91,
                          child: SvgPicture.asset(
                            ImagePath.prayerTimeIlustration,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const PrayerTimeRow(),
                    const SizedBox(height: 16),
                    const PrayerCalculationSelector(),
                    const SizedBox(height: 12),
                    const PrayerMethodInfoCard(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Set Location",
                    style: QPTextStyle.getSubHeading4SemiBold(context),
                  ),
                  Text(
                    "We need your location to show prayer times in your region.",
                    style: QPTextStyle.getDescription2Medium(context),
                  ),
                ],
              ),
            ),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Auto-detect location",
                            style: QPTextStyle.getBody2SemiBold(context)
                                .copyWith(
                                  color: QPColors.getColorBasedTheme(
                                    dark: QPColors.whiteRoot,
                                    light: QPColors.blackMassive,
                                    brown: QPColors.brownModeMassive,
                                    context: context,
                                  ),
                                ),
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Switch.adaptive(
                              activeTrackColor: QPColors.brandHeavy,
                              inactiveThumbColor: QPColors.getColorBasedTheme(
                                dark: QPColors.blackHeavy,
                                light: QPColors.whiteMassive,
                                brown: QPColors.whiteMassive,
                                context: context,
                              ),
                              inactiveTrackColor: QPColors.whiteSoft,
                              value: locationIsOn,
                              onChanged: isFetchingLocation
                                  ? null
                                  : (value) async {
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      final ok = await notifier.setAutoDetect(
                                        value,
                                      );
                                      if (!ok && value) {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Couldn't access location. Please enable location permission and services, then try again.",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (locationIsOn) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: (cooldownSeconds > 0 || isFetchingLocation)
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final ok = await notifier
                                      .updateLocationFromGps();
                                  if (!ok) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Couldn't update location. Please try again.",
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              isFetchingLocation
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: QPColors.getColorBasedTheme(
                                          dark: QPColors.whiteFair,
                                          light: QPColors.brandFair,
                                          brown: QPColors.brownModeMassive,
                                          context: context,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: QPColors.getColorBasedTheme(
                                          dark: QPColors.whiteFair,
                                          light: QPColors.brandFair,
                                          brown: QPColors.brownModeMassive,
                                          context: context,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          2,
                                        ), // Set radius here
                                      ),
                                      padding: const EdgeInsets.all(2),

                                      child: const Icon(
                                        Icons.refresh,
                                        size: 10,
                                        color: QPColors.whiteMassive,
                                      ),
                                    ),
                              const SizedBox(width: 6),
                              Text(
                                isFetchingLocation
                                    ? "Updating location..."
                                    : cooldownSeconds > 0
                                    ? "Update Location (${cooldownSeconds}s)"
                                    : "Update Location",
                                style:
                                    QPTextStyle.getDescription2Medium(
                                      context,
                                    ).copyWith(
                                      decoration: TextDecoration.underline,
                                      color: QPColors.getColorBasedTheme(
                                        dark: QPColors.whiteFair,
                                        light: QPColors.brandFair,
                                        brown: QPColors.brownModeMassive,
                                        context: context,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    InkWell(
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          RoutePaths.routeLocationManualPage,
                        );
                        notifier.refresh();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Set location manually",
                            style: QPTextStyle.getBody2SemiBold(context)
                                .copyWith(
                                  color: QPColors.getColorBasedTheme(
                                    dark: QPColors.whiteRoot,
                                    light: QPColors.blackMassive,
                                    brown: QPColors.brownModeMassive,
                                    context: context,
                                  ),
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
