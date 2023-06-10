import 'package:flutter/material.dart';

class AdaptiveThemeDialog extends StatelessWidget {
  const AdaptiveThemeDialog({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: child,
    );
  }
}
