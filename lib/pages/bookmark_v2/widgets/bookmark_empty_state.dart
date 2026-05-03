import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';

class BookmarkEmptyState extends StatelessWidget {
  const BookmarkEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: QPColors.getColorBasedTheme(
                dark: QPColors.darkModeHeavy,
                light: QPColors.whiteSoft,
                brown: QPColors.brownModeSoft,
                context: context,
              ),
            ),
            child: Image.asset(_emptyStateImagePath(context)),
          ),
        ),
        const SizedBox(height: 50),
        Text(
          'Ayah not found',
          style: QPTextStyle.getSubHeading2SemiBold(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          message,
          style: QPTextStyle.getSubHeading4Regular(context).copyWith(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.whiteRoot,
              light: QPColors.whiteFair,
              brown: QPColors.brownModeMassive,
              context: context,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () {
            final navigationBar =
                mainNavbarGlobalKey.currentWidget as BottomNavigationBar;
            navigationBar.onTap!(0);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6.5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.blackHeavy,
                light: QPColors.whiteMassive,
                brown: QPColors.brownModeRoot,
                context: context,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: QPColors.getColorBasedTheme(
                  dark: QPColors.blackFair,
                  light: Colors.transparent,
                  brown: QPColors.brownModeHeavy,
                  context: context,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 0.9),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Start Reading",
                style: QPTextStyle.getButton1SemiBold(context).copyWith(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteFair,
                    light: QPColors.brandFair,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _emptyStateImagePath(BuildContext context) {
    final mode = QPThemeData.getThemeModeBasedContext(context);
    switch (mode) {
      case QPThemeMode.brown:
        return ImagePath.emptyStateBrown;
      case QPThemeMode.dark:
        return ImagePath.emptyStateDark;
      default:
        return ImagePath.emptyStateLight;
    }
  }
}
