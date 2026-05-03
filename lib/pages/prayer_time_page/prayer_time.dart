import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/widgets/prayer_calculation_selector.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/widgets/prayer_method_info_card.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/widgets/prayer_time_row.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';

class PrayerTimePage extends ConsumerWidget {
  const PrayerTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityName =
        ref.watch(prayerTimeProvider.select((s) => s.cityName));
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        Column(
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
                                    Text(
                                      cityName ?? "",
                                      style: QPTextStyle.getBaseTextStyle(
                                        context,
                                      ).copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                            "Set location Manually",
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
