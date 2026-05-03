import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';

class HistoryInfoBox extends StatelessWidget {
  const HistoryInfoBox({
    super.key,
    required this.title,
    required this.icon,
    required this.mainInfo,
    required this.description,
    required this.startPageInIndex,
    this.onRefreshParentWidget,
  });

  final String title;
  final IconData icon;
  final String mainInfo;
  final String description;
  final int startPageInIndex;
  final VoidCallback? onRefreshParentWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final dynamic param = await Navigator.pushNamed(
          context,
          RoutePaths.routeSurahPage,
          arguments: SuratPageV3Param(
            startPageInIndex: startPageInIndex,
            isStartTracking: true,
          ),
        );

        if (onRefreshParentWidget != null && param is SuratPageV3OnPopParam) {
          onRefreshParentWidget!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: Row(
          children: [
            Icon(icon, color: QPColors.brandFair),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: QPTextStyle.getDescription2Regular(context).copyWith(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteHeavy,
                      light: QPColors.brandFair,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mainInfo,
                  style: QPTextStyle.getButton2SemiBold(context).copyWith(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.whiteFair,
                      light: QPColors.blackFair,
                      brown: QPColors.brownModeMassive,
                      context: context,
                    ),
                  ),
                ),
                Text(
                  description,
                  style: QPTextStyle.baseTextStyle.copyWith(
                    fontWeight: QPFontWeight.regular,
                    fontSize: 8,
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.blackRoot,
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
    );
  }
}
