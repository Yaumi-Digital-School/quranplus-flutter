import 'package:flutter/material.dart';

class AdaptiveThemeDialog extends StatelessWidget {
  const AdaptiveThemeDialog({
    Key? key,
    required this.child,
    this.borderRadiusValue = 8,
    this.contentPadding = const EdgeInsets.all(0),
  }) : super(key: key);

  final Widget child;
  final double borderRadiusValue;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadiusValue),
        ),
      ),
      child: Padding(
        padding: contentPadding,
        child: child,
      ),
    );
  }
}
