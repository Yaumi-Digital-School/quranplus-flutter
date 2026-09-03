import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_themed_colors.dart';

class SelectReciterAudioPreviewButton extends StatelessWidget {
  const SelectReciterAudioPreviewButton({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        color: context.qpColors.resolve(
          context.qpColors.brand100,
          dark: QPColors.brandFair,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(icon, color: QPColors.whiteFair, size: 12)),
    );
  }
}
