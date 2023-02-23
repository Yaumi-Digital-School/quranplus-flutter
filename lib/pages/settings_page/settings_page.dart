import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qurantafsir_flutter/pages/account_page/account_page.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qurantafsir_flutter/widgets/registration_view.dart';
import 'package:qurantafsir_flutter/widgets/sign_in_bottom_sheet.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final GeneralBottomSheet _generalBottomSheet = GeneralBottomSheet();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final navigationBar =
            mainNavbarGlobalKey.currentWidget as BottomNavigationBar;
        navigationBar.onTap!(0);

        return false;
      },
      child:
          StateNotifierConnector<SettingsPageStateNotifier, SettingsPageState>(
        stateNotifierProvider:
            StateNotifierProvider<SettingsPageStateNotifier, SettingsPageState>(
          (StateNotifierProviderRef<SettingsPageStateNotifier,
                  SettingsPageState>
              ref) {
            return SettingsPageStateNotifier(
              repository: ref.watch(authenticationService),
              sharedPreferenceService:
                  ref.watch(sharedPreferenceServiceProvider),
            );
          },
        ),
        onStateNotifierReady: (notifier, ref) async =>
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
                automaticallyImplyLeading: false,
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
              child: state.authenticationStatus ==
                      AuthenticationStatus.authenticated
                  ? _buildUserView(
                      context,
                      state,
                      notifier,
                      ref,
                    )
                  : RegistrationView(
                      nextWidget: Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 41,
                        ),
                        child: Column(
                          children: [
                            ButtonSecondary(
                              label: 'Sign In with Google',
                              onTap: _onTapButtonSignIn(
                                context,
                                notifier,
                                ref,
                                type: SignInType.google,
                              ),
                              leftIcon: IconPath.iconGoogle,
                            ),
                            if (Platform.isIOS) ...[
                              const SizedBox(
                                height: 16,
                              ),
                              ButtonSecondary(
                                label: 'Sign In with Apple',
                                onTap: _onTapButtonSignIn(
                                  context,
                                  notifier,
                                  ref,
                                  type: SignInType.apple,
                                ),
                                leftIcon: IconPath.iconApple,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  _onTapButtonSignIn(
    BuildContext context,
    SettingsPageStateNotifier notifier,
    WidgetRef ref, {
    required SignInType type,
  }) {
    return () async {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        notifier.signIn(
          ref: ref,
          type: type,
          onAccountDeleted: () {
            SignInBottomSheet.showAccountDeletedInfo(context: context);
          },
          onSuccess: () {
            ref.read(dioServiceProvider.notifier).state = DioService(
              baseUrl: EnvConstants.baseUrl!,
              accessToken:
                  ref.read(sharedPreferenceServiceProvider).getApiToken(),
              aliceService: ref.read(aliceServiceProvider),
            );
            ref.read(bookmarksService).clearBookmarkAndMergeFromServer();
            final BottomNavigationBar navbar =
                mainNavbarGlobalKey.currentWidget as BottomNavigationBar;
            navbar.onTap!(0);
          },
          onGeneralError: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Failed to sign in'),
                ),
              );
          },
        );
      } else {
        _generalBottomSheet.showNoInternetBottomSheet(
          context,
          () => Navigator.pop(context),
        );
      }
    };
  }

  Widget _buildUserView(
    BuildContext context,
    SettingsPageState state,
    SettingsPageStateNotifier notifier,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
                  context,
                  () => Navigator.pop(context),
                );
              }
            },
            child: _buildImageButton(
              'Account',
              IconPath.iconAccounnt,
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
                    aliceService: ref.read(aliceServiceProvider),
                    accessToken: '',
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
                  context,
                  () => Navigator.pop(context),
                );
              }
            },
            child: _buildImageButton(
              'Sign out',
              IconPath.iconLogout,
              exit500,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quran Plus Version",
                  style: bodyRegular2,
                ),
                const VersionAppWidget(),
              ],
            ),
          ),
        ],
      ),
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

  Future<void> navigateAfterLogin({
    required BuildContext context,
    required SettingsPageStateNotifier notifier,
  }) async {
    final ForceLoginParam? param = await notifier.getForceLoginInformation();
    if (param == null) {
      Navigator.of(context).pushReplacementNamed(
        RoutePaths.routeMain,
      );

      return;
    }

    Map<String, dynamic> routeArgs = param.arguments ?? <String, dynamic>{};
    Object? routeParams;

    switch (param.nextPath) {
      case RoutePaths.routeSurahPage:
        routeParams = SuratPageV3Param(
          startPageInIndex: routeArgs['startPageInIndex'],
          isStartTracking: routeArgs['isStartTracking'],
        );
        break;
      default:
    }

    Navigator.pushNamed(
      context,
      param.nextPath ?? '',
      arguments: routeParams,
    );
  }
}

class VersionAppWidget extends StatefulWidget {
  const VersionAppWidget({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<VersionAppWidget> createState() => _VersionAppWidget();
}

class _VersionAppWidget extends State<VersionAppWidget> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _packageInfo == null ? '' : _packageInfo!.version,
      style: bodyRegular2,
    );
  }
}
