import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';

class RegistrationView extends StatelessWidget {
  const RegistrationView({Key? key, required this.nextWidget})
      : super(key: key);

  final Widget nextWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Image.asset(
          ImagePath.logoQuranPlusPotrait,
          width: 83,
          height: 100,
        ),
        const SizedBox(height: 24),
        Text(
          'Why I must Sign in?',
          style: QPTextStyle.getSubHeading2SemiBold(context),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Signing in to Quran Plus with your Google Account can help you experience all of the benefits. Here’s what you get when you sign in:',
                style: QPTextStyle.getBody3Regular(context),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    IconPath.iconSync,
                    width: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sync Bookmark and Favorite data',
                          style: QPTextStyle.getSubHeading4SemiBold(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help you synchronize and keep your bookmark and favorite data on your device',
                          style: QPTextStyle.getBody3Regular(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    IconPath.iconHabitArrow,
                    width: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Add progress and set target',
                              style:
                                  QPTextStyle.getSubHeading4SemiBold(context),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            _buildNewFlag(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You can add your daily reading progress manually or record it and set your own reading target',
                          style: QPTextStyle.getBody3Regular(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    IconPath.iconGroupMember,
                    width: 24,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'See all members reading progress',
                              style:
                                  QPTextStyle.getSubHeading4SemiBold(context),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            _buildNewFlag(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All members progress are visible and hopefully can motivate you to reading more Qur’an and compete in goodness',
                          style: QPTextStyle.getBody3Regular(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        nextWidget,
      ],
    );
  }

  Widget _buildNewFlag() {
    return Container(
      decoration: const BoxDecoration(
        color: QPColors.brandFair,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      height: 13,
      width: 26,
      child: const Center(
        child: Text(
          'New',
          style: TextStyle(
            fontSize: 8,
            color: QPColors.whiteMassive,
            fontWeight: QPFontWeight.bold,
          ),
        ),
      ),
    );
  }
}
