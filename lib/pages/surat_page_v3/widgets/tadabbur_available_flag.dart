import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class TadabburAvailableFlag extends StatelessWidget {
  const TadabburAvailableFlag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book, size: 14),
          const SizedBox(width: 4),
          Text(
            'Tadabbur Available',
            style: QPTextStyle.getButton3Medium(context).copyWith(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.brandFair,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
