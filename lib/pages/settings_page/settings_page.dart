import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/account_page/account_page.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/change_theme_bottom_sheet.dart';
import 'package:qurantafsir_flutter/pages/settings_page/widgets/list_item_widget.dart';
import 'package:qurantafsir_flutter/pages/settings_page/widgets/version_app_widget.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/models/force_login_param.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qurantafsir_flutter/widgets/horizontal_divider.dart';
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
                foregroundColor: Theme.of(context).colorScheme.primary,
                centerTitle: true,
                title: const Text(
                  'Settings',
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

  Widget _buildUserView(
    BuildContext context,
    SettingsPageState state,
    SettingsPageStateNotifier notifier,
    WidgetRef ref,
  ) {
    final stateTheme = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListItemWidget(
            iconPath: IconPath.iconAccount,
            onTap: () {
              _onAccountTap(context);
            },
            title: 'Account',
          ),
          const HorizontalDivider(),
          ListItemWidget(
            iconPath: IconPath.iconTheme,
            onTap: () {
              _onThemesTap(context);
            },
            title: "Themes",
            subtitle: _getModeString(stateTheme),
          ),
          const HorizontalDivider(),
          ListItemWidget(
            iconPath: IconPath.iconLogout,
            onTap: () {
              _onLogoutTap(context, notifier, ref);
            },
            title: "Sign out",
            customColor: QPColors.errorFair,
          ),
          const HorizontalDivider(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quran Plus Version",
                style: QPTextStyle.getSubHeading3Regular(context).copyWith(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteRoot,
                    light: QPColors.whiteFair,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                ),
              ),
              const VersionAppWidget(),
            ],
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

  String _getModeString(QPThemeMode mode) {
    switch (mode) {
      case QPThemeMode.dark:
        return "Dark Mode";
      case QPThemeMode.brown:
        return "Brown Mode";
      default:
        return "Light Mode";
    }
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
          onSuccess: () async {
            await ref.read(habitDailySummaryService).syncHabit(
                  connectivityResult: connectivityResult,
                );
            await ref.read(bookmarksService).clearBookmarkAndMergeFromServer();

            ref.read(dioServiceProvider.notifier).state = DioService(
              baseUrl: EnvConstants.baseUrl!,
              accessToken:
                  ref.read(sharedPreferenceServiceProvider).getApiToken(),
              aliceService: ref.read(aliceServiceProvider),
            );
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

  void _onAccountTap(BuildContext context) async {
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
  }

  void _onThemesTap(BuildContext context) {
    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: const ChangeThemeBottomSheet(),
    );
  }

  void _onLogoutTap(
    BuildContext context,
    SettingsPageStateNotifier notifier,
    WidgetRef ref,
  ) async {
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
  }
}
