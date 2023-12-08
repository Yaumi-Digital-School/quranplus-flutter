import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';

import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class SettingsPageMenuItem extends StatelessWidget {
  const SettingsPageMenuItem({
    this.icon,
    this.iconData,
    required this.onTap,
    required this.title,
    this.subtitle,
    this.customColor,
    Key? key,
  }) : super(key: key);

  final StoredIcon? icon;
  final IconData? iconData;
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
            if (icon != null)
              SvgPicture.asset(
                icon!.path,
                colorFilter: ColorFilter.mode(
                  customColor ?? Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
            if (iconData != null)
              Icon(
                iconData,
                color: customColor ?? Theme.of(context).colorScheme.primary,
                size: 24,
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
