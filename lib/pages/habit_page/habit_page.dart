import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_progress/habit_progress_view.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/authentication_status.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/registration_view.dart';
import 'package:qurantafsir_flutter/widgets/sign_in_bottom_sheet.dart';

class HabitPage extends StatelessWidget {
  HabitPage({Key? key}) : super(key: key);

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
      child: StateNotifierConnector<HabitPageStateNotifier, HabitPageState>(
        stateNotifierProvider:
            StateNotifierProvider<HabitPageStateNotifier, HabitPageState>(
          (StateNotifierProviderRef<HabitPageStateNotifier, HabitPageState>
              ref) {
            return HabitPageStateNotifier(
              repository: ref.watch(authenticationService),
              sharedPreferenceService:
                  ref.watch(sharedPreferenceServiceProvider),
            );

            // ignore: dead_code
          },
        ),
        onStateNotifierReady: (notifier, ref) async =>
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
                automaticallyImplyLeading: false,
                foregroundColor: Colors.black,
                centerTitle: true,
                title: const Text(
                  'Reading Habit Tracker',
                  style: TextStyle(fontSize: 16),
                ),
                backgroundColor: backgroundColor,
              ),
            ),
            backgroundColor: QPColors.whiteFair,
            body:
                state.authenticationStatus == AuthenticationStatus.authenticated
                    ? const HabitProgressView()
                    : SingleChildScrollView(
                        child: RegistrationView(
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
    HabitPageStateNotifier notifier,
    WidgetRef ref, {
    required SignInType type,
  }) {
    return () async {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        notifier.signIn(
          type: type,
          ref: ref,
          onAccountDeletedError: () {
            SignInBottomSheet.showAccountDeletedInfo(context: context);
          },
          onSuccess: () async {
            await ref.read(habitDailySummaryService).syncHabit(
                  connectivityResult: connectivityResult,
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
                  content: Text('Sign in Gagal'),
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
}
