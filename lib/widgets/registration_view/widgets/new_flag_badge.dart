import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class NewFlagBadge extends StatelessWidget {
  const NewFlagBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: QPColors.brandFair,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      height: 13,
      width: 26,
      child: const Center(
        child: Text(
          'New',
          style: TextStyle(
            fontSize: 8,
            color: QPColors.whiteMassive,
            fontWeight: QPFontWeight.bold,
          ),
        ),
      ),
    );
  }
}