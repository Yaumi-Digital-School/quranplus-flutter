import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/Icon.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

import '../../shared/constants/theme.dart';

class HabitPage extends StatelessWidget {
  HabitPage({Key? key}) : super(key: key);

  final GeneralBottomSheet _generalBottomSheet = GeneralBottomSheet();

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HabitPageStateNotifier, HabitPageState>(
      stateNotifierProvider:
          StateNotifierProvider<HabitPageStateNotifier, HabitPageState>(
        (StateNotifierProviderRef<HabitPageStateNotifier, HabitPageState> ref) {
          return HabitPageStateNotifier(
            repository: ref.watch(authenticationService),
            sharedPreferenceService: ref.watch(sharedPreferenceServiceProvider),
          );

          // ignore: dead_code
        },
      ),
      onStateNotifierReady: (notifier) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        HabitPageState state,
        HabitPageStateNotifier notifier,
        WidgetRef ref,
      ) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(54.0),
              child: AppBar(
                elevation: 0.7,
                foregroundColor: Colors.black,
                centerTitle: true,
                title: const Text(
                  'Habit',
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: backgroundColor,
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: state.authenticationStatus ==
                        AuthenticationStatus.authenticated
                    ? Center()
                    : _buildGuestView(
                        context,
                        state,
                        notifier,
                        ref,
                      ),
              ),
            ));
      },
    );
  }

  Widget _buildGuestView(
    BuildContext context,
    HabitPageState state,
    HabitPageStateNotifier notifier,
    WidgetRef ref,
  ) {
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
                    IconPath.iconCollaborate,
                    width: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contribute to Quran Tafsir',
                            style: captionSemiBold1),
                        const SizedBox(width: 8),
                        Text(
                            'When signed in, you can contribute to the development of this App by giving us feedback and experience using Quran Tafsir',
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
        ButtonSecondary(
          label: 'Sign In with Google',
          onTap: () async {
            var connectivityResult = await Connectivity().checkConnectivity();
            if (connectivityResult != ConnectivityResult.none) {
              notifier.signInWithGoogle(() {
                Navigator.of(context)
                    .pushReplacementNamed(AppConstants.routeMain);
                ref.read(dioServiceProvider.notifier).state = DioService(
                  baseUrl: EnvConstants.baseUrl!,
                  accessToken:
                      ref.read(sharedPreferenceServiceProvider).getApiToken(),
                );
                ref.read(bookmarksService).clearBookmarkAndMergeFromServer();
              }, () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Sign in Gagal'),
                    ),
                  );
              });
            } else {
              _generalBottomSheet.showNoInternetBottomSheet(
                  // TODO changes to refresh action
                  context,
                  () => Navigator.pop(context));
            }
          },
          leftIcon: IconPath.iconGoogle,
        ),
      ],
    );
  }
}
