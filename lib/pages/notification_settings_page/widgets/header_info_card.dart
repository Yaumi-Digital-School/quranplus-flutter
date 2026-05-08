import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qurantafsir_flutter/shared/constants/illustration.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class HeaderInfoCard extends StatelessWidget {
  const HeaderInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: QPColors.brandRoot,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            left: 22,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Get notifications every adhan\nand reminder to read Quran!',
                style: QPTextStyle.getSubHeading4SemiBold(
                  context,
                ).copyWith(color: QPColors.blackMassive),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SvgPicture.asset(Illustration.notificationCard.path),
          ),
        ],
      ),
    );
  }
}
