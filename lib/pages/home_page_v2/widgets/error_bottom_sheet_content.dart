import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class ErrorBottomSheetContent extends StatelessWidget {
  const ErrorBottomSheetContent({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error, color: QPColors.errorFair, size: 32),
        const SizedBox(height: 28),
        Text(
          title,
          style: QPTextStyle.getHeading1SemiBold(
            context,
          ).copyWith(color: QPColors.blackMassive),
        ),
        const SizedBox(height: 24),
        Text(
          description,
          style: QPTextStyle.getBody2Regular(
            context,
          ).copyWith(color: QPColors.neutral700),
        ),
        const SizedBox(height: 24),
        ButtonSecondary(
          label: "Close",
          onTap: () {
            Navigator.pop(context);
          },
          textStyle: QPTextStyle.getButton2SemiBold(
            context,
          ).copyWith(color: QPColors.brandFair),
        ),
      ],
    );
  }
}
