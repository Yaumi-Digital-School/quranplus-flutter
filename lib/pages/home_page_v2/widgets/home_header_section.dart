import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/adzan_card/adzan_card_widget.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/widgets/home_habit_card.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class HomeHeaderSection extends ConsumerWidget {
  const HomeHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(homePageProvider.select((s) => s.name));

    return Container(
      color: QPColors.getColorBasedTheme(
        dark: QPColors.darkModeMassive,
        light: QPColors.whiteFair,
        brown: QPColors.brownModeRoot,
        context: context,
      ),
      child: Stack(
        children: [
          Container(
            height: name.isEmpty ? 150 : 200,
            color: QPColors.getColorBasedTheme(
              dark: QPColors.darkModeMassive,
              light: QPColors.brandFair,
              brown: QPColors.brownModeRoot,
              context: context,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      StoredIcon.iconQuranPlus.path,
                      colorFilter: ColorFilter.mode(
                        QPColors.getColorBasedTheme(
                          dark: QPColors.whiteFair,
                          light: QPColors.whiteFair,
                          brown: QPColors.brownModeMassive,
                          context: context,
                        ),
                        BlendMode.srcIn,
                      ),
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      ImagePath.quranPlusText,
                      colorFilter: ColorFilter.mode(
                        QPColors.getColorBasedTheme(
                          dark: QPColors.whiteFair,
                          light: QPColors.whiteFair,
                          brown: QPColors.brownModeMassive,
                          context: context,
                        ),
                        BlendMode.srcIn,
                      ),
                      height: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (name.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Assalamu'alaikum, $name",
                      style: QPTextStyle.getSubHeading4SemiBold(context)
                          .copyWith(
                            color: QPColors.getColorBasedTheme(
                              dark: QPColors.whiteFair,
                              light: QPColors.whiteMassive,
                              brown: QPColors.brownModeMassive,
                              context: context,
                            ),
                          ),
                    ),
                  ),
                const AdzanCardWidget(),
                const HomeHabitCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
