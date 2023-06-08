import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/read_tadabbur/read_tadabbur_page.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';

class TadabburSurahCard extends StatelessWidget {
  const TadabburSurahCard({
    Key? key,
    required this.title,
    required this.availableTadabbur,
    required this.lastUpdatedAt,
    required this.surahID,
  }) : super(key: key);

  final String title;
  final int availableTadabbur;
  final DateTime lastUpdatedAt;
  final int surahID;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutePaths.routeReadTadabbur,
          arguments: ReadTadabburParam(
            surahId: surahID,
            surahName: title,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: QPColors.getColorBasedTheme(
            dark: QPColors.darkModeHeavy,
            light: QPColors.whiteMassive,
            brown: QPColors.brownModeFair,
            context: context,
          ),
          border: Border.fromBorderSide(
            BorderSide(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.darkModeFair,
                light: QPColors.whiteRoot,
                brown: QPColors.brownModeHeavy,
                context: context,
              ),
            ),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
            right: 16,
            left: 16,
            bottom: 16,
          ),
          child: _buildInformation(context),
        ),
      ),
    );
  }

  Widget _buildInformation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: QPTextStyle.getSubHeading3SemiBold(context),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 16,
                        color: QPColors.getColorBasedTheme(
                          dark: QPColors.whiteFair,
                          light: QPColors.blackFair,
                          brown: QPColors.brownModeMassive,
                          context: context,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '$availableTadabbur Tadabbur available',
                        style: QPTextStyle.getSubHeading4SemiBold(context)
                            .copyWith(
                          color: QPColors.getColorBasedTheme(
                            dark: QPColors.whiteFair,
                            light: QPColors.blackFair,
                            brown: QPColors.brownModeMassive,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Icon(
              Icons.keyboard_arrow_right,
              size: 24,
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.blackFair,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          DateCustomUtils.getDateRangeFormatted(lastUpdatedAt),
          style: QPTextStyle.getDescription2Regular(context).copyWith(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.blackSoft,
              light: QPColors.blackSoft,
              brown: QPColors.brownModeMassive,
              context: context,
            ),
          ),
        ),
      ],
    );
  }
}
