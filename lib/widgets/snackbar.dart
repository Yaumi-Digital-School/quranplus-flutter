import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

class GeneralSnackBar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showModalSnackBar({
    required BuildContext context,
    required String text,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: QPColors.blackFair,
      content: Text(text),
    ));
  }
}
