import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/registration_view/widgets/registration_view_feature_information.dart';
import 'package:qurantafsir_flutter/widgets/sign_in_bottom_sheet.dart';

class RegistrationView extends ConsumerWidget {
  const RegistrationView({
    Key? key,
    this.onSuccessLogin,
    this.shouldNavigateTabToHome = true,
  }) : super(key: key);

  final VoidCallback? onSuccessLogin;
  final bool shouldNavigateTabToHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const RegistrationViewFeatureInformation(
                icon: StoredIcon.iconSync,
                title: 'Sync Bookmark and Favorite data',
                description:
                    'Help you synchronize and keep your bookmark and favorite data on your device',
              ),
              const SizedBox(height: 24),
              const RegistrationViewFeatureInformation(
                icon: StoredIcon.iconHabitArrow,
                title: 'Add progress and set target',
                description:
                    'You can add your daily reading progress manually or record it and set your own reading target',
              ),
              const SizedBox(height: 24),
              const RegistrationViewFeatureInformation(
                icon: StoredIcon.iconGroupMember,
                title: 'See all members reading progress',
                description:
                    'All members progress are visible and hopefully can motivate you to reading more Qur’an and compete in goodness',
              ),
              const SizedBox(height: 24),
              const RegistrationViewFeatureInformation(
                iconData: Icons.update,
                title: 'Stay updated with our latest information',
                description:
                    'Receive updates on the latest developments and accessing valuable information about QuranPlus, enriching your experience with the app.',
              ),
              const SizedBox(height: 24),
              const RegistrationViewFeatureInformation(
                iconData: Icons.notifications_rounded,
                title: 'Set notification',
                description:
                    'Get notifications every adhan and notifications to read Quran. You can also set notifications based on your preference to read Quran.',
                isNew: true,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: 41,
          ),
          child: Column(
            children: [
              ButtonSecondary(
                label: 'Sign In with Google',
                onTap: () {
                  _onTapButtonSignIn(
                    context: context,
                    type: SignInType.google,
                    ref: ref,
                  );
                },
                leftIcon: StoredIcon.iconGoogle.path,
              ),
              if (Platform.isIOS) ...[
                const SizedBox(
                  height: 16,
                ),
                ButtonSecondary(
                  label: 'Sign In with Apple',
                  onTap: () {
                    _onTapButtonSignIn(
                      context: context,
                      type: SignInType.apple,
                      ref: ref,
                    );
                  },
                  leftIcon: StoredIcon.iconApple.path,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onTapButtonSignIn({
    required BuildContext context,
    required SignInType type,
    required WidgetRef ref,
  }) async {
    final ConnectivityStatus connectivityStatus =
        ref.watch(internetConnectionStatusProviders);
    final AuthenticationService authService = ref.read(authenticationService);
    if (connectivityStatus == ConnectivityStatus.isConnected) {
      final SignInResult res = await authService.signIn(type: type);
      if (context.mounted) {
        switch (res) {
          case SignInResult.failedAccountDeleted:
            SignInBottomSheet.showAccountDeletedInfo(context: context);
            break;
          case SignInResult.failedGeneral:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Failed to sign in'),
                ),
              );
            break;
          case SignInResult.success:
          default:
            await ref.read(habitDailySummaryService).syncHabit(
                  connectivityStatus: connectivityStatus,
                );
            await ref.read(bookmarksService).clearBookmarkAndMergeFromServer();

            if (shouldNavigateTabToHome) {
              final BottomNavigationBar navbar =
                  mainNavbarGlobalKey.currentWidget as BottomNavigationBar;
              navbar.onTap!(0);
            }

            onSuccessLogin?.call();
            break;
        }
      }
    }
  }
}
