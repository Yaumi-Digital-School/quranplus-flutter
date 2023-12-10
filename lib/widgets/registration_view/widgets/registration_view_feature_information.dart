import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/registration_view/widgets/new_flag_badge.dart';

class RegistrationViewFeatureInformation extends StatelessWidget {
  const RegistrationViewFeatureInformation({
    Key? key,
    this.icon,
    this.iconData,
    required this.title,
    required this.description,
    this.isNew = false,
  }) : super(key: key);

  final StoredIcon? icon;
  final IconData? iconData;
  final String title;
  final String description;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Image.asset(
            icon!.path,
            width: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        if (iconData != null)
          Icon(
            iconData,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: QPTextStyle.getSubHeading4SemiBold(context),
                  ),
                  if (isNew) ...<Widget>[
                    const SizedBox(
                      width: 8,
                    ),
                    const NewFlagBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: QPTextStyle.getBody3Regular(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
