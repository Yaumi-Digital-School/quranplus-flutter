import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_themed_colors.dart';

class GeneralAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GeneralAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
  });

  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(54.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: context.qpColors.resolve(
            context.qpColors.brand100,
            light: QPColors.blackMassive,
          ),
          size: 24,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: QPTextStyle.getSubHeading2SemiBold(context),
      ),
      automaticallyImplyLeading: false,
      elevation: 0.7,
      centerTitle: true,
      actions: actions,
    );
  }
}
