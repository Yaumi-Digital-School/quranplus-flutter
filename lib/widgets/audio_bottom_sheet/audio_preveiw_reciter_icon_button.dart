import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

class AudioPreviewReciterIconButton extends StatelessWidget {
  const AudioPreviewReciterIconButton({
    Key? key,
    required this.icon,
  }) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        color: QPColors.getColorBasedTheme(
          dark: QPColors.brandFair,
          light: QPColors.brandFair,
          brown: QPColors.brownModeMassive,
          context: context,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: QPColors.whiteFair,
          size: 12,
        ),
      ),
    );
  }
}
