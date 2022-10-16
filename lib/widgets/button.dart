import 'package:flutter/material.dart';

import '../shared/constants/theme.dart';

class ButtonSecondary extends StatelessWidget {
  const ButtonSecondary({
    required this.label,
    required this.onTap,
    this.leftIcon,
  });

  final String? leftIcon;

  final String label;
  final Function()? onTap;
  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(6.0),
            primary: Colors.white,
            onPrimary: primary500,
            elevation: 2,
            minimumSize: const Size.fromHeight(40),
          ),
          onPressed: onTap,
          child: _childButton(leftIcon, label)),
    );
  }

  Widget _childButton(String? leftIcon, String label) {
    if (leftIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ImageIcon(
            AssetImage(leftIcon),
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            label,
            style: bodySemibold2.apply(color: primary500),
          )
        ],
      );
    }
    return Text(
      label,
      style: bodySemibold2.apply(color: primary500),
    );
  }
}

class ButtonNeutral extends StatelessWidget {
  const ButtonNeutral({
    required this.label,
    required this.onTap,
  });

  final String label;
  final Function()? onTap;
  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: darkGreen, width: 2)),
            padding: const EdgeInsets.all(6.0),
            primary: Colors.white,
            onPrimary: primary500,
            elevation: 0,
            minimumSize: const Size.fromHeight(40),
          ),
          onPressed: onTap,
          child: Text(label),
        ));
  }
}
