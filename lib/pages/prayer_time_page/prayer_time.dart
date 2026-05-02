import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';

class PrayerTimePage extends ConsumerWidget {
  const PrayerTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimeProvider);
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
                                      state.cityName ?? "",
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
                    _buildPrayerTimeItem(context, state),
                    const SizedBox(height: 16),
                    _buildCalculationDropdowns(context, ref, notifier),
                    const SizedBox(height: 12),
                    _buildMethodDescription(context, ref),
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

  Widget _buildPrayerTimeItem(BuildContext context, PrayerTimeState state) {
    List<Widget> widgetPrayerTime = <Widget>[];

    for (final PrayerTimesList prayerTime in PrayerTimesList.values) {
      widgetPrayerTime.add(
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
                prayerTime.name,
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
                state.getPrayerTimesFormatted(prayerTime),
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
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widgetPrayerTime,
    );
  }

  Widget _buildCalculationDropdowns(
    BuildContext context,
    WidgetRef ref,
    PrayerTimeNotifier notifier,
  ) {
    final calculationMethod = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(madhubProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: calculationMethod,
                items:
                    ['singapore', 'muslimworldleague', 'egyptian', 'ummAlqura']
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(
                              _formatMethodName(method),
                              style: QPTextStyle.getDescription2Regular(
                                context,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (newMethod) {
                  if (newMethod != null) {
                    ref.read(calculationMethodProvider.notifier).set(newMethod);
                    notifier.updatePrayerTimes(newMethod, madhab);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: madhab,
                items: ['shafi', 'hanafi']
                    .map(
                      (school) => DropdownMenuItem(
                        value: school,
                        child: Text(
                          school == 'shafi' ? 'Syafi\'i' : 'Hanafi',
                          style: QPTextStyle.getDescription2Regular(context),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (newSchool) {
                  if (newSchool != null) {
                    ref.read(madhubProvider.notifier).set(newSchool);
                    notifier.updatePrayerTimes(calculationMethod, newSchool);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatMethodName(String method) {
    switch (method) {
      case 'singapore':
        return 'Singapore';
      case 'muslimworldleague':
        return 'Muslim World League';
      case 'egyptian':
        return 'Egyptian';
      case 'ummAlqura':
        return 'Umm Al-Qura';
      default:
        return method;
    }
  }

  Widget _buildMethodDescription(BuildContext context, WidgetRef ref) {
    final calculationMethod = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(madhubProvider);

    String methodDescription = _getMethodDescription(calculationMethod);
    String madhubText = madhab == 'shafi' ? 'Syafi\'i' : 'Hanafi';

    return SizedBox(
      width: double.infinity,
      child: Text(
        'Metode: $methodDescription · Mazhab $madhubText',
        style: QPTextStyle.getDescription2Medium(context),
        textAlign: TextAlign.left,
      ),
    );
  }

  String _getMethodDescription(String method) {
    switch (method) {
      case 'singapore':
        return 'Singapore region (Indonesia, Malaysia, Singapore)';
      case 'muslimworldleague':
        return 'Muslim World League';
      case 'egyptian':
        return 'Egyptian General Authority of Survey';
      case 'ummAlqura':
        return 'Umm Al-Qura University (Saudi Arabia)';
      default:
        return method;
    }
  }
}
