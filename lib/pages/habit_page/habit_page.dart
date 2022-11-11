import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
import 'package:qurantafsir_flutter/widgets/registration_view.dart';

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
                    ? const Center()
                    : RegistrationView(
                        nextWidget: ButtonSecondary(
                          label: 'Sign In with Google',
                          onTap: () async {
                            var connectivityResult =
                                await Connectivity().checkConnectivity();
                            if (connectivityResult != ConnectivityResult.none) {
                              notifier.signInWithGoogle(() {
                                Navigator.of(context).pushReplacementNamed(
                                    AppConstants.routeMain);
                                ref.read(dioServiceProvider.notifier).state =
                                    DioService(
                                  baseUrl: EnvConstants.baseUrl!,
                                  accessToken: ref
                                      .read(sharedPreferenceServiceProvider)
                                      .getApiToken(),
                                );
                                ref
                                    .read(bookmarksService)
                                    .clearBookmarkAndMergeFromServer();
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
                                  context, () => Navigator.pop(context));
                            }
                          },
                          leftIcon: IconPath.iconGoogle,
                        ),
                      ),
              ),
            ));
      },
    );
  }
}
