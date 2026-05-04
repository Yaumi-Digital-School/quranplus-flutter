import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class BookmarkListItem extends StatelessWidget {
  const BookmarkListItem({
    super.key,
    required this.iconAssetPath,
    required this.surahName,
    required this.subtitleText,
    this.trailingText,
    required this.onTap,
  });

  final String iconAssetPath;
  final String surahName;
  final String subtitleText;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    print(subtitleText);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        minLeadingWidth: 20,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(iconAssetPath)),
              ),
            ),
          ],
        ),
        title: Text(
          'Surat $surahName',
          style: QPTextStyle.getSubHeading3SemiBold(context),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: <Widget>[
            Text(
              subtitleText,
              style: QPTextStyle.getSubHeading4Regular(context).copyWith(
                color: QPColors.getColorBasedTheme(
                  dark: QPColors.whiteRoot,
                  light: QPColors.blackFair,
                  brown: QPColors.brownModeMassive,
                  context: context,
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: trailingText == null
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    trailingText!,
                    textAlign: TextAlign.right,
                    style: QPTextStyle.getSubHeading3Regular(context),
                  ),
                ],
              ),
        onTap: onTap,
      ),
    );
  }
}
