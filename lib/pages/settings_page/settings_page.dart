import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/account_page/account_page.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/shared/utils/result_status.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final GeneralBottomSheet _generalBottomSheet = GeneralBottomSheet();

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<SettingsPageStateNotifier, SettingsPageState>(
      stateNotifierProvider:
          StateNotifierProvider<SettingsPageStateNotifier, SettingsPageState>(
              (StateNotifierProviderRef<SettingsPageStateNotifier,
                      SettingsPageState>
                  ref) {
        return SettingsPageStateNotifier(
          repository: ref.watch(authenticationService),
          sharedPreferenceService: ref.watch(sharedPreferenceServiceProvider),
        );
      }),
      onStateNotifierReady: (notifier) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        SettingsPageState state,
        SettingsPageStateNotifier notifier,
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
                'Settings',
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
                  ? _buildUserView(
                      context,
                      state,
                      notifier,
                      ref,
                    )
                  : _buildGuestView(
                      context,
                      state,
                      notifier,
                      ref,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserView(
    BuildContext context,
    SettingsPageState state,
    SettingsPageStateNotifier notifier,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () async {
            var connectivityResult = await Connectivity().checkConnectivity();
            if (connectivityResult != ConnectivityResult.none) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AccountPage();
              }));
            } else {
              _generalBottomSheet.showNoInternetBottomSheet(
                  // TODO changes to refresh action
                  context,
                  () => Navigator.pop(context));
            }
          },
          child: _buildImageButton(
            'Account',
            'images/icon_account.png',
            neutral900,
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () async {
            var connectivityResult = await Connectivity().checkConnectivity();
            if (connectivityResult != ConnectivityResult.none) {
              notifier.signOut(() {
                ref.read(dioServiceProvider.notifier).state = DioService(
                  baseUrl: EnvConstants.baseUrl!,
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Sign out Berhasil'),
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
          child: _buildImageButton(
            'Sign out',
            'images/icon_logout.png',
            exit500,
          ),
        ),
      ],
    );
  }

  Widget _buildGuestView(
    BuildContext context,
    SettingsPageState state,
    SettingsPageStateNotifier notifier,
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
                    'images/icon_sync.png',
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
                    'images/icon_update_now.png',
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
                    'images/icon_collaborate.png',
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
        ElevatedButton.icon(
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
          onPressed: () async {
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
          icon: state.resultStatus == ResultStatus.inProgress
              ? Container()
              : Image.asset(
                  'images/icon_google.png',
                  width: 16,
                ),
          label: state.resultStatus == ResultStatus.inProgress
              ? const CircularProgressIndicator()
              : Text(
                  'Sign In with Google',
                  style: bodySemibold2.apply(color: primary500),
                ),
        ),
      ],
    );
  }

  Widget _buildImageButton(String name, String imgAsset, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: neutral400),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                imgAsset,
                width: 24,
                color: color,
              ),
              const SizedBox(width: 16),
              Text(
                name,
                style: subHeadingSemiBold2.apply(color: color),
              ),
            ],
          ),
          Icon(
            Icons.keyboard_arrow_right,
            size: 24,
            color: color,
          ),
        ],
      ),
    );
  }
}
