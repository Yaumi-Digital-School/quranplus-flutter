import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

Future<T?> showQPGeneralDialog<T>({
  required BuildContext context,
  required Widget Function(
    BuildContext,
  )
      builder,
  bool isBarrierDismissable = true,
}) async {
  final Color barrierColor = QPColors.getColorBasedTheme(
    dark: Colors.black87,
    light: Colors.black54,
    brown: Colors.black54,
    context: context,
  );

  return await showDialog<T>(
    barrierColor: barrierColor,
    barrierDismissible: isBarrierDismissable,
    context: context,
    builder: builder,
  );
}
