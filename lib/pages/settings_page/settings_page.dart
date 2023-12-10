import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/account_page/account_page.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/widgets/change_theme_bottom_sheet.dart';
import 'package:qurantafsir_flutter/pages/settings_page/widgets/settings_page_menu_item.dart';
import 'package:qurantafsir_flutter/pages/settings_page/widgets/version_app_widget.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/horizontal_divider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
        onStateNotifierReady: (notifier, ref) => notifier.initStateNotifier(),
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
              child: Padding(
                padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SettingsPageMenuItem(
                      iconData: Icons.person,
                      onTap: () {
                        _onAccountTap(
                          context,
                          ref.watch(internetConnectionStatusProviders),
                          ref.watch(authenticationService),
                        );
                      },
                      title: 'Account',
                    ),
                    const HorizontalDivider(),
                    SettingsPageMenuItem(
                      iconData: Icons.notifications_rounded,
                      onTap: () {
                        // TODO: add redirection
                      },
                      title: 'Notifications',
                    ),
                    const HorizontalDivider(),
                    SettingsPageMenuItem(
                      icon: StoredIcon.iconSunClock,
                      onTap: () {
                        // TODO: add redirection
                      },
                      title: 'Prayer Times',
                    ),
                    const HorizontalDivider(),
                    SettingsPageMenuItem(
                      icon: StoredIcon.iconTheme,
                      onTap: () {
                        _onThemesTap(context);
                      },
                      title: "Themes",
                      subtitle: ref.watch(themeProvider).labelMode,
                    ),
                    SettingsPageMenuItem(
                      iconData: Icons.star,
                      onTap: () {
                        // TODO: add redirection
                      },
                      title: 'Rate Us',
                    ),
                    const HorizontalDivider(),
                    if (state.authenticationStatus ==
                        AuthenticationStatus.authenticated) ...<Widget>[
                      const HorizontalDivider(),
                      SettingsPageMenuItem(
                        icon: StoredIcon.iconLogout,
                        onTap: () {
                          _onLogoutTap(
                            context,
                            notifier,
                            ref.watch(internetConnectionStatusProviders),
                          );
                        },
                        title: "Sign out",
                        customColor: QPColors.errorFair,
                      ),
                      const HorizontalDivider(),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quran Plus Version",
                          style: QPTextStyle.getSubHeading3Regular(context)
                              .copyWith(
                            color: QPColors.getColorBasedTheme(
                              dark: QPColors.blackFair,
                              light: QPColors.blackFair,
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
              ),
            ),
          );
        },
      ),
    );
  }

  void _onAccountTap(
    BuildContext context,
    ConnectivityStatus connectivityStatus,
    AuthenticationService authenticationService,
  ) {
    if (!authenticationService.isLoggedIn) {
      Navigator.pushNamed(
        context,
        RoutePaths.routeLogin,
      );

      return;
    }

    if (connectivityStatus == ConnectivityStatus.isConnected &&
        context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AccountPage();
      }));
    } else if (context.mounted) {
      GeneralBottomSheet.showNoInternetBottomSheet(
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

  Future<void> _onLogoutTap(
    BuildContext context,
    SettingsPageStateNotifier notifier,
    ConnectivityStatus connectivityStatus,
  ) async {
    if (connectivityStatus == ConnectivityStatus.isConnected) {
      await notifier.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Sign out Berhasil'),
            ),
          );
      }

      return;
    }

    if (context.mounted) {
      GeneralBottomSheet.showNoInternetBottomSheet(
        context,
        () => Navigator.pop(context),
      );
    }
  }
}
