import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/account_deletion/account_deletion_view_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/account_deletion/widgets/account_deletion_bottom_sheet.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/dio_service.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/snackbar.dart';

class AccountDeletionInformationView extends StatelessWidget {
  const AccountDeletionInformationView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<AccountDeletionViewStateNotifier,
        AccountDeletionViewState>(
      stateNotifierProvider: StateNotifierProvider<
          AccountDeletionViewStateNotifier, AccountDeletionViewState>((ref) {
        return AccountDeletionViewStateNotifier(
          userApi: ref.read(userApiProvider),
          sharedPreferenceService: ref.read(sharedPreferenceServiceProvider),
          authenticationService: ref.read(authenticationService),
        );
      }),
      builder: (
        _,
        AccountDeletionViewState state,
        AccountDeletionViewStateNotifier notifier,
        WidgetRef ref,
      ) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: AppBar(
              elevation: 0.7,
              foregroundColor: Colors.black,
              centerTitle: true,
              title: Text(
                'Delete Account',
                style: QPTextStyle.getSubHeading2SemiBold(context),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'What happens after I delete my account?',
                  style: QPTextStyle.getSubHeading2SemiBold(context),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'After you delete your account, all data associated with this account (saved bookmarks, favorites, reading progress and target) will be permanently deleted and irrecoverable.',
                  textAlign: TextAlign.justify,
                  style: QPTextStyle.getBody3Regular(context).copyWith(
                    // Todo: check color based on theme
                    color: QPColors.blackFair,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    text:
                        'If you want to register your new account with the same email, reach us at ',
                    // Todo: check color based on theme
                    style: QPTextStyle.getBody3Regular(context).copyWith(
                      color: QPColors.blackFair,
                    ),
                    children: [
                      // Todo: check color based on theme
                      TextSpan(
                        text: 'yaumi.indonesia@gmail.com',
                        style: QPTextStyle.getBody3Medium(context),
                      ),
                      TextSpan(
                        text: ' and ',
                        // Todo: check color based on theme
                        style: QPTextStyle.getBody3Regular(context).copyWith(
                          color: QPColors.blackFair,
                        ),
                      ),
                      TextSpan(
                        text: 'rizaherzego@gmail.com',
                        style: QPTextStyle.getBody3Medium(context),
                      ),
                      TextSpan(
                        text: ' to proceed your registration.',
                        style: QPTextStyle.getBody3Regular(context).copyWith(
                          // Todo: check color based on theme
                          color: QPColors.blackFair,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      AccountDeletionBottomSheet.showDeletionConfirmation(
                        context: context,
                        onConfirm: () async {
                          final bool isSuccess = await notifier.deleteAccount();

                          if (isSuccess) {
                            ref.read(dioServiceProvider.notifier).state =
                                DioService(
                              baseUrl: EnvConstants.baseUrl!,
                              aliceService: ref.read(aliceServiceProvider),
                              accessToken: '',
                            );

                            if (context.mounted) {
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            }

                            final BottomNavigationBar navbar =
                                mainNavbarGlobalKey.currentWidget
                                    as BottomNavigationBar;
                            navbar.onTap!(0);

                            if (context.mounted) {
                              GeneralSnackBar.showModalSnackBar(
                                context: context,
                                text: 'Your account has been deleted',
                              );
                            }

                            return;
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            GeneralSnackBar.showModalSnackBar(
                              context: context,
                              text: 'An error has occurred, please try again',
                            );
                          }
                        },
                      );
                    },
                    child: Text(
                      'Delete account',
                      style:
                          QPTextStyle.getSubHeading3SemiBold(context).copyWith(
                        // Todo: check color based on theme
                        color: QPColors.errorFair,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
