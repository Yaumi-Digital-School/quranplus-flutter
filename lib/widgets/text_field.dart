import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class InputTotalPagesTextField extends StatelessWidget {
  final void Function(String) onChanged;
  final int? defaultValue;

  const InputTotalPagesTextField({
    Key? key,
    required this.onChanged,
    this.defaultValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 56,
      child: TextField(
        cursorColor: Colors.black,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: buttonMedium3.copyWith(color: neutral400),
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: EdgeInsets.zero,
          label: Center(
            child: Text(
              "0",
              style: buttonMedium3.copyWith(color: neutral400),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: neutral500, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: neutral500, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: neutral500, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
