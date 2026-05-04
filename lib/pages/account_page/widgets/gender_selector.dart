import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.selectedGenderInitial,
    required this.hasError,
    required this.onChanged,
  });

  static const List<String> _options = ['Male', 'Female'];

  final String selectedGenderInitial;
  final bool hasError;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gender',
              style: QPTextStyle.getSubHeading2SemiBold(context),
            ),
            if (hasError)
              Text(
                '*',
                style: subHeadingSemiBold2.apply(color: errorColor),
              ),
          ],
        ),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: selectedGenderInitial,
          onChanged: onChanged,
          child: Row(
            children: [
              for (final item in _options) ...[
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 8),
                      child: Radio(
                        value: item[0],
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (states) => Theme.of(context).colorScheme.primary,
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      item,
                      style: QPTextStyle.getSubHeading3Regular(context),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 2),
          Text(
            'Required',
            style: captionLight2.apply(color: errorColor),
          ),
        ],
      ],
    );
  }
}
