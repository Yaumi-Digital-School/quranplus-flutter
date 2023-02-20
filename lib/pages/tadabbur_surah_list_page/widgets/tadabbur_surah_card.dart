import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
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
    return Container(
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
            Expanded(child: _buildInformation()),
            GestureDetector(
              onTap: () {
                // TODO : Add navigate to tadabbur ayah list
              },
              child: const Icon(
                Icons.keyboard_arrow_right,
                size: 24,
                color: QPColors.blackFair,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: QPTextStyle.subHeading3SemiBold,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const Icon(
              Icons.menu_book,
              size: 10,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              '$availableTadabbur Tadabbur available',
              style: QPTextStyle.subHeading4SemiBold.copyWith(
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
          style: QPTextStyle.description2Regular.copyWith(
            color: QPColors.blackSoft,
          ),
        ),
      ],
    );
  }
}
