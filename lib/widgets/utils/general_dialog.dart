import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_themed_colors.dart';

Future<T?> showQPGeneralDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isBarrierDismissable = true,
}) async {
  final Color barrierColor = context.qpColors.resolve(
    context.qpColors.brand100,
    light: Colors.black54,
    dark: Colors.black87,
    brown: Colors.black54,
  );

  return await showDialog<T>(
    barrierColor: barrierColor,
    barrierDismissible: isBarrierDismissable,
    context: context,
    builder: builder,
  );
}
