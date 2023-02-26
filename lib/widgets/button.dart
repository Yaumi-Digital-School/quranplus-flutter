import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

enum ButtonSize {
  regular,
  small,
  extendable,
}

class ButtonSecondary extends StatelessWidget {
  const ButtonSecondary({
    Key? key,
    required this.label,
    required this.onTap,
    this.leftIcon,
    this.textStyle,
    this.size = ButtonSize.extendable,
  }) : super(key: key);

  final String? leftIcon;
  final String label;
  final TextStyle? textStyle;
  final Function()? onTap;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final double width = size == ButtonSize.regular
        ? 165
        : size == ButtonSize.extendable
            ? double.infinity
            : 130;
    final double labelFontSize = size == ButtonSize.regular ? 14 : 12;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(6.0),
          primary: Colors.white,
          onPrimary: primary500,
          elevation: 1,
          minimumSize: const Size.fromHeight(40),
        ),
        onPressed: onTap,
        child: _childButton(leftIcon, label, labelFontSize),
      ),
    );
  }

  Widget _childButton(String? leftIcon, String label, double labelFontSize) {
    if (leftIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            image: AssetImage(leftIcon),
            width: 24,
            height: 24,
            fit: BoxFit.scaleDown,
            color: null,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            label,
            style: bodySemibold2
                .apply(
                  color: primary500,
                )
                .copyWith(
                  fontSize: labelFontSize,
                ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: textStyle ??
          bodySemibold2.apply(color: primary500).copyWith(
                fontSize: labelFontSize,
              ),
    );
  }
}

class ButtonNeutral extends StatelessWidget {
  const ButtonNeutral({
    Key? key,
    required this.label,
    required this.onTap,
    this.textStyle,
    this.size = ButtonSize.extendable,
  }) : super(key: key);

  final String label;
  final Function()? onTap;
  final TextStyle? textStyle;
  final ButtonSize size;

  @override
  Widget build(
    BuildContext context,
  ) {
    final double width = size == ButtonSize.regular
        ? 165
        : size == ButtonSize.extendable
            ? double.infinity
            : 100;
    final double labelFontSize = size == ButtonSize.regular ? 14 : 12;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: darkGreen, width: 1),
          ),
          padding: const EdgeInsets.all(6.0),
          primary: Colors.transparent,
          onPrimary: primary500,
          elevation: 0,
          minimumSize: const Size.fromHeight(40),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: textStyle ??
              bodySemibold2.copyWith(
                color: darkGreen,
                fontSize: labelFontSize,
              ),
        ),
      ),
    );
  }
}

class ButtonPrimary extends StatelessWidget {
  const ButtonPrimary({
    Key? key,
    required this.label,
    required this.onTap,
    this.size = ButtonSize.extendable,
    this.textStyle,
  }) : super(key: key);

  final String label;
  final Function()? onTap;
  final ButtonSize size;
  final TextStyle? textStyle;

  @override
  Widget build(
    BuildContext context,
  ) {
    final double width = size == ButtonSize.regular
        ? 165
        : size == ButtonSize.extendable
            ? double.infinity
            : 100;
    final double labelFontSzie = size == ButtonSize.regular ? 14 : 12;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(6.0),
          primary: darkGreen,
          onPrimary: Colors.white,
          minimumSize: const Size.fromHeight(40),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(fontSize: labelFontSzie),
        ),
      ),
    );
  }
}

class ButtonBrandSoft extends StatelessWidget {
  final String title;
  final Widget? leftWidget;
  final void Function()? onTap;

  const ButtonBrandSoft({
    required this.title,
    this.leftWidget,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: QPColors.brandSoft,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            leftWidget ??
                const Icon(
                  Icons.menu_book,
                  size: 12,
                  color: QPColors.brandFair,
                ),
            const SizedBox(width: 10),
            Text(
              title,
              style:
                  QPTextStyle.button2Medium.copyWith(color: QPColors.brandFair),
            ),
          ],
        ),
      ),
    );
  }
}
