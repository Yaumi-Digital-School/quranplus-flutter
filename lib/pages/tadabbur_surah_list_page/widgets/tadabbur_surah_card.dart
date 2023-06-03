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
        decoration: const BoxDecoration(
          color: QPColors.whiteMassive,
          border: Border.fromBorderSide(
            BorderSide(
              color: QPColors.whiteRoot,
            ),
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
            right: 16,
            left: 16,
            bottom: 24,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInformation(context)),
              const Icon(
                Icons.keyboard_arrow_right,
                size: 24,
                color: QPColors.blackFair,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: QPTextStyle.getSubHeading3SemiBold(context),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const Icon(
              Icons.menu_book,
              size: 12,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              '$availableTadabbur Tadabbur available',
              style: QPTextStyle.getSubHeading4SemiBold(context).copyWith(
                // Todo: check color based on theme
                color: QPColors.blackFair,
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
            // Todo: check color based on theme
            color: QPColors.blackSoft,
          ),
        ),
      ],
    );
  }
}
