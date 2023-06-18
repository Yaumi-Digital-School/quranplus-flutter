import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/models/theme_option_color_param.dart';

class ThemeBoxOptionWidget extends StatelessWidget {
  const ThemeBoxOptionWidget({
    required this.theme,
    required this.colorParam,
    this.onTap,
    this.isSelected = false,
    Key? key,
  }) : super(key: key);
  final String theme;
  final ThemeOptionColorParam colorParam;
  final bool isSelected;
  final VoidCallback? onTap;

  final int itemCount = 3;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 22,
              right: 12,
              left: 12,
            ),
            decoration: BoxDecoration(
              color: colorParam.firstColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.fromBorderSide(
                BorderSide(
                  color:
                      isSelected ? QPColors.brandFair : colorParam.firstColor,
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
                color: colorParam.secondColor,
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
                      color: colorParam.thirdColor,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: QPColors.brandFair,
                  ),
                ),
              Text(
                theme,
                style: QPTextStyle.getButton2SemiBold(context).copyWith(
                  color: isSelected ? QPColors.brandFair : QPColors.blackFair,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
