import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class RegistrationView extends StatelessWidget {
  const RegistrationView({Key? key, required this.nextWidget})
      : super(key: key);

  final Widget nextWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'images/logo.png',
          width: 150,
        ),
        const SizedBox(height: 48),
        Text('Why I must Sign in?', style: subHeadingSemiBold2),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 65),
          child: Column(
            children: [
              Text(
                'Signing in to Quran Tafsir with your Google Account can help you experience all of the benefits. Here’s what you get when you sign in:',
                style: captionRegular2,
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
                        Text('Sync Bookmark and Favorite data',
                            style: captionSemiBold1),
                        const SizedBox(width: 8),
                        Text(
                            'Help you synchronize dan keep your bookmark and favorite data on your device',
                            style: captionRegular2),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    IconPath.iconUpdateNow,
                    width: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Get the latest update', style: captionSemiBold1),
                        const SizedBox(width: 8),
                        Text(
                            'You will be notify of the latest version of Quran Tafsir',
                            style: captionRegular2),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    IconPath.iconTargetArrow,
                    width: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Build reading habit and set',
                                style: captionSemiBold1),
                            SizedBox(width: 5),
                            Container(
                              decoration: BoxDecoration(
                                  color: darkGreen,
                                  borderRadius: BorderRadius.circular(4)),
                              height: 13,
                              width: 26,
                              child: Center(
                                child: Text('New',
                                    style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.white,
                                        fontWeight: bold)),
                              ),
                            )
                          ],
                        ),
                        Text(
                          'target',
                          style: captionSemiBold1,
                        ),
                        const SizedBox(width: 8),
                        Text(
                            'Add your daily qur’an reading progress manually or record it and set your own target',
                            style: captionRegular2),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        nextWidget,
      ],
    );
  }
}
