import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class ListItemWidget extends StatelessWidget {
  const ListItemWidget({
    required this.iconPath,
    required this.onTap,
    required this.title,
    this.subtitle,
    this.customColor,
    Key? key,
  }) : super(key: key);

  final String iconPath;
  final String title;
  final String? subtitle;
  final Color? customColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              color: customColor ?? Theme.of(context).colorScheme.primary,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: QPTextStyle.getSubHeading2SemiBold(context)
                  .copyWith(color: customColor),
            ),
            const Spacer(),
            if (subtitle != null)
              Text(
                subtitle!,
                style: QPTextStyle.getBody3Regular(context)
                    .copyWith(color: customColor),
              ),
            const SizedBox(width: 16),
            Icon(
              Icons.keyboard_arrow_right,
              size: 24,
              color: customColor ?? Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
