import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class CitiesNotFoundWidget extends StatelessWidget {
  const CitiesNotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.not_listed_location,
            size: 24,
            color: QPColors.blackFair,
          ),
          const SizedBox(height: 8),
          const Text("Location not found"),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: QPTextStyle.getDescription2Medium(context),
              children: [
                const TextSpan(text: 'Check your spelling or activate '),
                TextSpan(
                  text: 'Auto-detect location',
                  style: QPTextStyle.getDescription2Medium(context).copyWith(
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pop(context);
                    },
                ),
                const TextSpan(text: ' to set your location.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
