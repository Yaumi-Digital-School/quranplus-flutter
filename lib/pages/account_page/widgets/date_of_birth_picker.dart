import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class DateOfBirthPicker extends StatelessWidget {
  const DateOfBirthPicker({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.hasError,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  final String day;
  final String month;
  final String year;
  final bool hasError;
  final ValueChanged<String> onDayChanged;
  final ValueChanged<String> onMonthChanged;
  final ValueChanged<String> onYearChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Date of Birth',
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
        Row(
          children: [
            _field(
              context: context,
              width: 70,
              value: day,
              hint: 'DD',
              maxLength: 2,
              onChanged: (value) {
                if (value.isEmpty) {
                  onDayChanged('');
                } else if (int.parse(value) > 31) {
                  onDayChanged('31');
                } else {
                  onDayChanged(value);
                }
              },
            ),
            const SizedBox(width: 16),
            _field(
              context: context,
              width: 70,
              value: month,
              hint: 'MM',
              maxLength: 2,
              onChanged: (value) {
                if (value.isEmpty) {
                  onMonthChanged('');
                } else if (int.parse(value) > 12) {
                  onMonthChanged('12');
                } else {
                  onMonthChanged(value);
                }
              },
            ),
            const SizedBox(width: 16),
            _field(
              context: context,
              width: 90,
              value: year,
              hint: 'YYYY',
              maxLength: 4,
              onChanged: (value) {
                if (value.isEmpty) {
                  onYearChanged('');
                  return;
                }
                final maxYear = int.parse(DateFormat.y().format(DateTime.now())) - 1;
                if (int.parse(value) > maxYear) {
                  onYearChanged(maxYear.toString());
                } else {
                  onYearChanged(value);
                }
              },
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            'Required',
            style: captionLight2.apply(color: errorColor),
          ),
        ],
      ],
    );
  }

  Widget _field({
    required BuildContext context,
    required double width,
    required String value,
    required String hint,
    required int maxLength,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          ),
        ),
        maxLength: maxLength,
        style: QPTextStyle.getSubHeading3Medium(context),
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          errorText: hasError ? '' : null,
          errorStyle: const TextStyle(height: 0),
          counterText: '',
          contentPadding: const EdgeInsets.all(8),
          hintText: hint,
          hintStyle: bodyMedium2.copyWith(
            color: Theme.of(context).hintColor,
          ),
          border: enabledInputBorder,
          enabledBorder: enabledInputBorder,
          errorBorder: errorInputBorder,
          focusedErrorBorder: errorInputBorder,
        ),
      ),
    );
  }
}
