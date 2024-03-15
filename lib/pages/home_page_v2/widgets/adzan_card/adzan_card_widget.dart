import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/prayer_times_list.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class AdzanCardWidget extends StatelessWidget {
  const AdzanCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
              SvgPicture.asset(
                PrayerTimes.ashr.icon.path,
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
              const SizedBox(width: 4),
              Text(
                PrayerTimes.ashr.label,
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
                "15:28",
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
              SvgPicture.asset(
                StoredIcon.iconLocation.path,
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
              const SizedBox(width: 4),
              Text(
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
