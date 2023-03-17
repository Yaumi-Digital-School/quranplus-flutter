import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class StepParams {
  final String buttonTitle;
  final String description;
  final StepDirection direction;
  final Widget mainWidget;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double marginTopMainWidget;

  StepParams({
    required this.buttonTitle,
    required this.description,
    required this.direction,
    required this.mainWidget,
    this.bottom,
    this.left,
    this.right,
    this.top,
    this.marginTopMainWidget = 0,
  });
}

enum StepDirection {
  column,
  row,
  rowReverse,
}

class StepWidget extends StatelessWidget {
  final void Function() onTapNextButton;
  final StepParams stepParams;

  const StepWidget({
    required this.onTapNextButton,
    required this.stepParams,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stepParams.direction == StepDirection.column) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          stepParams.mainWidget,
          const SizedBox(height: 12),
          Text(
            stepParams.description,
            textAlign: TextAlign.center,
            style:
                QPTextStyle.subHeading3SemiBold.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: onTapNextButton,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: const BoxDecoration(
                color: QPColors.brandFair,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                stepParams.buttonTitle,
                style: QPTextStyle.button2Medium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: stepParams.direction == StepDirection.row
          ? TextDirection.ltr
          : TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        stepParams.mainWidget,
        const SizedBox(width: 16),
        Expanded(
          child: Stack(
            children: [
              Positioned(
                top: stepParams.marginTopMainWidget,
                right:
                    stepParams.direction == StepDirection.rowReverse ? 0 : null,
                child: Column(
                  crossAxisAlignment: stepParams.direction == StepDirection.row
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Text(
                      stepParams.description,
                      style: QPTextStyle.subHeading3SemiBold
                          .copyWith(color: Colors.white),
                      textAlign: stepParams.direction == StepDirection.row
                          ? TextAlign.left
                          : TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: onTapNextButton,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: QPColors.brandFair,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          stepParams.buttonTitle,
                          style: QPTextStyle.button2Medium
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
