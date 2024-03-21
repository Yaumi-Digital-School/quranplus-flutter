import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/adzan_card/adzan_card_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers/prayer_times_notifier.dart';

class AdzanCardWidget extends ConsumerStatefulWidget {
  const AdzanCardWidget({super.key});

  @override
  ConsumerState<AdzanCardWidget> createState() => _AdzanCardWidgetState();
}

class _AdzanCardWidgetState extends ConsumerState<AdzanCardWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final PrayerTimeState prayerTimes = ref.read(prayerTimeProvider);
      if (prayerTimes.prayerTimes == null) {
        final PrayerTimeStateNotifier prayerTimesStateNotifier =
            ref.read(prayerTimeProvider.notifier);
        prayerTimesStateNotifier.initStateNotifier();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AdzanState adzanState = ref.watch(adzanCardProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              adzanState.prayerTimesList == null
                  ? Icon(
                      Icons.location_on,
                      size: 12,
                      color: QPColors.getColorBasedTheme(
                        dark: QPColors.whiteFair,
                        light: QPColors.brandFair,
                        brown: QPColors.brownModeMassive,
                        context: context,
                      ),
                    )
                  : SvgPicture.asset(
                      adzanState.prayerTimesList!.icon.path,
                      colorFilter: ColorFilter.mode(
                        QPColors.getColorBasedTheme(
                          dark: QPColors.whiteFair,
                          light: QPColors.brandFair,
                          brown: QPColors.brownModeMassive,
                          context: context,
                        ),
                        BlendMode.srcIn,
                      ),
                      height: 12,
                      width: 12,
                    ),
              const SizedBox(width: 4),
              Text(
                adzanState.prayerTimesList == null
                    ? "no location set"
                    : adzanState.prayerTimesList!.label,
                style: QPTextStyle.getDescription1Regular(
                  context,
                ).copyWith(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteFair,
                    light: QPColors.brandFair,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                adzanState.prayerTimesList == null || adzanState.date == null
                    ? ""
                    : "${adzanState.date!.hour}:${adzanState.date!.minute}",
                style: QPTextStyle.getDescription1Regular(
                  context,
                ).copyWith(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteFair,
                    light: QPColors.brandFair,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (adzanState.prayerTimesList != null)
                Container(
                  width: 1,
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.blackFair,
                    light: QPColors.whiteRoot,
                    brown: QPColors.brownModeHeavy,
                    context: context,
                  ),
                  height: 16,
                ),
              const SizedBox(width: 12),
              if (adzanState.prayerTimesList != null)
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
              if (adzanState.prayerTimesList != null)
                Text(
                  // TODO set location
                  "Depok City, West Java",
                  style: QPTextStyle.getDescription1Regular(
                    context,
                  ).copyWith(
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
          InkWell(
            onTap: () {},
            child: SvgPicture.asset(
              StoredIcon.iconArrowRight.path,
              colorFilter: ColorFilter.mode(
                QPColors.getColorBasedTheme(
                  dark: QPColors.whiteFair,
                  light: QPColors.brandFair,
                  brown: QPColors.brownModeMassive,
                  context: context,
                ),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
