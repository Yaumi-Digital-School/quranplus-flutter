import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';

class TadabburAyahCard extends StatelessWidget {
  const TadabburAyahCard({
    Key? key,
    required this.ayahNumber,
    required this.title,
    required this.source,
    required this.createdAt,
    required this.ayahId,
  }) : super(key: key);

  final String title;
  final String source;
  final int ayahNumber;
  final DateTime createdAt;
  final int ayahId;

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
        padding: const EdgeInsets.all(16),
        child: _buildInformation(),
      ),
    );
  }

  Widget _buildInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ayah $ayahNumber",
          style: QPTextStyle.button3Medium,
        ),
        const SizedBox(
          height: 8,
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
              title,
              style: QPTextStyle.button1SemiBold.copyWith(
                color: QPColors.blackFair,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                // TODO : Add navigate to tadabbur content
              },
              child: const Icon(
                Icons.keyboard_arrow_right,
                size: 24,
                color: QPColors.blackFair,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Text(
              source,
              style: QPTextStyle.button3SemiBold
                  .copyWith(color: QPColors.blackFair),
            ),
            const SizedBox(width: 8),
            Text(
              DateCustomUtils.getDateRangeFormatted(createdAt),
              style: QPTextStyle.description2Regular.copyWith(
                color: QPColors.blackSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
