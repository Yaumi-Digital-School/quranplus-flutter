import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/prayer_times_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times_list.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/apis/model/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

class PrayerTimePage extends ConsumerStatefulWidget {
  const PrayerTimePage({Key? key}) : super(key: key);

  @override
  ConsumerState<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends ConsumerState<PrayerTimePage> {
  late PrayerTimeStateNotifier prayerTimeNotifier;

  @override
  void initState() {
    prayerTimeNotifier = ref.read(prayerTimeProvider.notifier);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PrayerTimeState state = ref.watch(prayerTimeProvider);
    bool value = false;
    print("Location CCondition");
    print(state.locationIsOn);

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
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              elevation: 1.2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
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
                              style:
                                  QPTextStyle.getSubHeading2SemiBold(context),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                color: QPColors.getColorBasedTheme(
                                  dark: QPColors.whiteFair,
                                  light: QPColors.brandSoft,
                                  brown: QPColors.brownModeMassive,
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
                                      "Depok, Jawabarat",
                                      style:
                                          QPTextStyle.getBaseTextStyle(context),
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
                          child: Image(
                            image: AssetImage(ImagePath.prayerTiimeIlustration),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildPrayerTimeItem(state),
                    const SizedBox(
                      height: 16,
                    ),
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
              elevation: 1.2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16.0,
                  8.0,
                  16.0,
                  16.0,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Auto-detect location",
                          style: QPTextStyle.getBody2SemiBold(context).copyWith(
                            color: QPColors.getColorBasedTheme(
                              dark: QPColors.whiteRoot,
                              light: QPColors.blackMassive,
                              brown: QPColors.brownModeMassive,
                              context: context,
                            ),
                          ),
                        ),
                        Switch(
                          value: state.locationIsOn,
                          onChanged: (value) {
                            if (value != state.locationIsOn) {
                              ref
                                  .read(prayerTimeProvider.notifier)
                                  .updateAutoDetectCondition(value);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Set location Manually",
                            style:
                                QPTextStyle.getBody2SemiBold(context).copyWith(
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

  Widget _buildPrayerTimeItem(PrayerTimeState state) {
    List<Widget> widgetPrayerTime = <Widget>[];

    for (int i = 0; i < PrayerTimesList.listPrayerTimes.length; i++) {
      widgetPrayerTime.add(
        Center(
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteFair,
                    light: QPColors.brandSoft,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
                child: SvgPicture.asset(
                  PrayerTimesList.listIconPrayerTimes[i],
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                  width: 16,
                  height: 16,
                  fit: BoxFit.none,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(PrayerTimesList.listPrayerTimes[i]),
              const SizedBox(
                height: 8,
              ),
              const Text("__:__"),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widgetPrayerTime,
    );
  }
}
