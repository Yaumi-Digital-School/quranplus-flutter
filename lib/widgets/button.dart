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
  final VoidCallback? onTap;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final double width = size == ButtonSize.regular
        ? 165
        : size == ButtonSize.extendable
            ? double.infinity
            : 130;
    final double labelFontSize = size == ButtonSize.regular ? 14 : 12;

    final Color borderColor = QPColors.getColorBasedTheme(
      dark: QPColors.blackFair,
      light: QPColors.whiteRoot,
      brown: QPColors.brownModeHeavy,
      context: context,
    );

    final Color backgroundColor = QPColors.getColorBasedTheme(
      dark: QPColors.blackHeavy,
      light: QPColors.whiteMassive,
      brown: QPColors.brownModeRoot,
      context: context,
    );

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            side: BorderSide(
              width: 1,
              color: borderColor,
            ),
          ),
          padding: const EdgeInsets.all(10.0),
          primary: backgroundColor,
          onPrimary: Colors.red,
          elevation: 1,
        ),
        onPressed: onTap,
        child: _childButton(
          leftIcon,
          label,
          labelFontSize,
          context,
        ),
      ),
    );
  }

  Widget _childButton(
    String? leftIcon,
    String label,
    double labelFontSize,
    BuildContext context,
  ) {
    final Color contentColor = QPColors.getColorBasedTheme(
      dark: QPColors.whiteFair,
      light: QPColors.brandFair,
      brown: QPColors.brownModeMassive,
      context: context,
    );

    final TextStyle labelStyle =
        QPTextStyle.getSubHeading4SemiBold(context).copyWith(
      fontSize: labelFontSize,
      color: contentColor,
    );

    if (leftIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            image: AssetImage(leftIcon),
            width: 24,
            height: 24,
            fit: BoxFit.scaleDown,
            color: contentColor,
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
      textAlign: TextAlign.center,
      style: textStyle ?? labelStyle,
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

    final Color contentColor = QPColors.getColorBasedTheme(
      dark: QPColors.whiteFair,
      light: QPColors.brandFair,
      brown: QPColors.brownModeMassive,
      context: context,
    );

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: contentColor, width: 1),
          ),
          padding: const EdgeInsets.all(10.0),
          primary: Colors.transparent,
          onPrimary: primary500,
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: textStyle ??
              bodySemibold2.copyWith(
                color: contentColor,
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
  final VoidCallback? onTap;
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
            : 130;
    final double labelFontSzie = size == ButtonSize.regular ? 14 : 12;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(10.0),
          primary: darkGreen,
          onPrimary: Colors.white,
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
              offset: const Offset(0, 0.9),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            if (leftWidget != null) leftWidget!,
            const SizedBox(width: 10),
            Text(
              title, // Todo: check color based on theme
              style: QPTextStyle.getButton2Medium(context)
                  .copyWith(color: QPColors.brandFair),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonPill extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData? icon;
  final String label;
  final Color? colorText;

  const ButtonPill({
    Key? key,
    required this.onTap,
    required this.label,
    this.icon,
    this.colorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        primary: Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: colorText ?? QPColors.brandFair,
                size: 17.0,
              ),
            const SizedBox(
              width: 4,
            ),
            Text(
              label,
              style: QPTextStyle.getSubHeading4SemiBold(context).copyWith(
                color: colorText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
