import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/tadabur_story_page.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_themed_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/utils/date_util.dart';

class TadabburAyahCard extends StatelessWidget {
  const TadabburAyahCard({
    super.key,
    required this.ayahNumber,
    required this.title,
    required this.source,
    required this.createdAt,
    required this.surahNumber,
    required this.tadabburId,
  });

  final String title;
  final String source;
  final int ayahNumber;
  final DateTime createdAt;
  final int surahNumber;
  final int tadabburId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutePaths.routeTadabburContent,
          arguments: TadabburStoryPageParams(tadabburId: tadabburId),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.qpColors.surface60,
          border: Border.fromBorderSide(
            BorderSide(color: context.qpColors.surface20),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildInformation(context),
        ),
      ),
    );
  }

  Widget _buildInformation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ayah $ayahNumber", style: QPTextStyle.getButton3Medium(context)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.menu_book, size: 16, color: context.qpColors.neutral100),
            const SizedBox(width: 8),
            Expanded(
              flex: 7,
              child: Text(
                title,
                style: QPTextStyle.getButton1SemiBold(
                  context,
                ).copyWith(color: context.qpColors.neutral100),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_right,
              size: 24,
              color: context.qpColors.neutral100,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              source,
              style: QPTextStyle.getButton3SemiBold(context).copyWith(
                color: context.qpColors.resolve(
                  context.qpColors.neutral100,
                  dark: QPColors.blackRoot,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateCustomUtils.getDateRangeFormatted(createdAt),
              style: QPTextStyle.getDescription2Regular(context).copyWith(
                color: context.qpColors.resolve(
                  context.qpColors.brand100,
                  light: QPColors.blackSoft,
                  dark: QPColors.blackRoot,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
