import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

class ThemeBoxOptionWidget extends StatelessWidget {
  const ThemeBoxOptionWidget({
    required this.firstColor,
    required this.secondColor,
    required this.thirdColor,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final Color firstColor;
  final Color secondColor;
  final Color thirdColor;
  final bool isSelected;
  final void Function() onTap;

  final int itemCount = 3;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(
          top: 22,
          right: 12,
          left: 12,
        ),
        decoration: BoxDecoration(
          color: firstColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.fromBorderSide(
            BorderSide(
              color: isSelected ? QPColors.brandFair : firstColor,
              width: 2,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 8,
            right: 8,
            left: 8,
            bottom: 4,
          ),
          decoration: BoxDecoration(
            color: secondColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: List.generate(
              itemCount,
              (index) => Container(
                height: 18,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: thirdColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}