import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/pages/account_page/account_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/shared/utils/form_status.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

class AccountPage extends StatelessWidget {
  AccountPage({Key? key}) : super(key: key);

  final List<String> _genderType = ['Male', 'Female'];
  final GeneralBottomSheet _generalBottomSheet = GeneralBottomSheet();

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<AccountPageStateNotifier, AccountPageState>(
      stateNotifierProvider:
          StateNotifierProvider<AccountPageStateNotifier, AccountPageState>(
        (ref) {
          return AccountPageStateNotifier(
            repository: ref.watch(authenticationService),
            sharedPreferenceService: ref.watch(sharedPreferenceServiceProvider),
          );
        },
      ),
      onStateNotifierReady: (notifier, ref) async =>
          await notifier.initStateNotifier(),
      builder: (
        BuildContext context,
        AccountPageState state,
        AccountPageStateNotifier notifier,
        _,
      ) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: AppBar(
              elevation: 0.7,
              foregroundColor: Colors.black,
              centerTitle: true,
              title: const Text(
                'Account',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: backgroundColor,
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Name',
                    style: subHeadingSemiBold2,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: state.name,
                        selection: TextSelection.collapsed(
                          offset: state.name.length,
                        ),
                      ),
                    ),
                    style: bodyMedium2,
                    onChanged: (value) {
                      notifier.nameChanged(value);
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      hintText: 'Name',
                      hintStyle: bodyMedium2.apply(color: neutral400),
                      border: enabledInputBorder,
                      enabledBorder: enabledInputBorder,
                      errorBorder: errorInputBorder,
                      focusedErrorBorder: errorInputBorder,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Email',
                    style: subHeadingSemiBold2,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: TextEditingController(text: state.email),
                    style: bodyMedium2.apply(color: neutral500),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      enabled: false,
                      contentPadding: const EdgeInsets.all(8),
                      hintText: 'email@gmail.com',
                      hintStyle: bodyMedium2.apply(color: neutral400),
                      border: enabledInputBorder,
                      enabledBorder: enabledInputBorder,
                      fillColor: neutral300,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Please complete the fields below',
                    style: bodyRegular2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Date of Birth',
                        style: subHeadingSemiBold2,
                      ),
                      if (state.formStatus == FormStatus.invalid &&
                          (state.dateOfMonth.isEmpty ||
                              state.month.isEmpty ||
                              state.year.isEmpty)) ...[
                        Text(
                          '*',
                          style: subHeadingSemiBold2.apply(color: errorColor),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.dateOfMonth,
                              selection: TextSelection.collapsed(
                                offset: state.dateOfMonth.length,
                              ),
                            ),
                          ),
                          maxLength: 2,
                          style: bodyMedium2,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (int.parse(value) > 31) {
                                notifier.dateOfMonthChanged('31');
                              } else {
                                notifier.dateOfMonthChanged(value);
                              }
                            } else {
                              notifier.dateOfMonthChanged('');
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            errorText:
                                (state.formStatus == FormStatus.invalid &&
                                        (state.dateOfMonth.isEmpty ||
                                            state.month.isEmpty ||
                                            state.year.isEmpty))
                                    ? ''
                                    : null,
                            errorStyle: const TextStyle(height: 0),
                            counterText: '',
                            contentPadding: const EdgeInsets.all(8),
                            hintText: 'DD',
                            hintStyle: bodyMedium2.apply(color: neutral400),
                            border: enabledInputBorder,
                            enabledBorder: enabledInputBorder,
                            errorBorder: errorInputBorder,
                            focusedErrorBorder: errorInputBorder,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.month,
                              selection: TextSelection.collapsed(
                                offset: state.month.length,
                              ),
                            ),
                          ),
                          maxLength: 2,
                          style: bodyMedium2,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (int.parse(value) > 12) {
                                notifier.monthChanged('12');
                              } else {
                                notifier.monthChanged(value);
                              }
                            } else {
                              notifier.monthChanged('');
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            errorText:
                                (state.formStatus == FormStatus.invalid &&
                                        (state.dateOfMonth.isEmpty ||
                                            state.month.isEmpty ||
                                            state.year.isEmpty))
                                    ? ''
                                    : null,
                            errorStyle: const TextStyle(height: 0),
                            counterText: '',
                            contentPadding: const EdgeInsets.all(8),
                            hintText: 'MM',
                            hintStyle: bodyMedium2.apply(color: neutral400),
                            border: enabledInputBorder,
                            enabledBorder: enabledInputBorder,
                            errorBorder: errorInputBorder,
                            focusedErrorBorder: errorInputBorder,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: state.year,
                              selection: TextSelection.collapsed(
                                offset: state.year.length,
                              ),
                            ),
                          ),
                          maxLength: 4,
                          style: bodyMedium2,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              var year = DateFormat.y().format(DateTime.now());
                              var yearInt = int.parse(year) - 1;
                              if (int.parse(value) > yearInt) {
                                notifier.yearChanged(yearInt.toString());
                              } else {
                                notifier.yearChanged(value);
                              }
                            } else {
                              notifier.yearChanged('');
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            errorText:
                                (state.formStatus == FormStatus.invalid &&
                                        (state.dateOfMonth.isEmpty ||
                                            state.month.isEmpty ||
                                            state.year.isEmpty))
                                    ? ''
                                    : null,
                            errorStyle: const TextStyle(height: 0),
                            counterText: '',
                            contentPadding: const EdgeInsets.all(8),
                            hintText: 'YYYY',
                            hintStyle: bodyMedium2.apply(color: neutral400),
                            border: enabledInputBorder,
                            enabledBorder: enabledInputBorder,
                            errorBorder: errorInputBorder,
                            focusedErrorBorder: errorInputBorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (state.formStatus == FormStatus.invalid &&
                      (state.dateOfMonth.isEmpty ||
                          state.month.isEmpty ||
                          state.year.isEmpty)) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Required',
                      style: captionLight2.apply(color: errorColor),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Gender',
                        style: subHeadingMedium2,
                      ),
                      if (state.formStatus == FormStatus.invalid &&
                          state.gender.isEmpty) ...[
                        Text(
                          '*',
                          style: subHeadingSemiBold2.apply(color: errorColor),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var item in _genderType) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 8),
                              child: Radio(
                                value: item[0],
                                groupValue: state.gender,
                                activeColor: neutral900,
                                onChanged: (value) {
                                  notifier.genderChanged(value);
                                },
                              ),
                            ),
                            Text(
                              item,
                              style: bodyRegular2,
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                      ],
                    ],
                  ),
                  if (state.formStatus == FormStatus.invalid &&
                      state.gender.isEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Required',
                      style: captionLight2.apply(color: errorColor),
                    ),
                  ],
                  const SizedBox(height: 48),
                  ButtonSecondary(
                    label: 'Save',
                    onTap: _onPressedButtonSave(
                      state.formStatus,
                      context,
                      notifier,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        RoutePaths.accountDeletion,
                      ),
                      child: Text(
                        'Delete my account',
                        style: QPTextStyle.getSubHeading3SemiBold(context)
                            .copyWith(
                          // Todo: check color based on theme
                          color: QPColors.errorFair,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _onPressedButtonSave(
    FormStatus formStatus,
    BuildContext context,
    AccountPageStateNotifier notifier,
  ) {
    if (formStatus == FormStatus.valid) {
      return () async {
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult != ConnectivityResult.none) {
          notifier.saveButtonChecked(() {
            Navigator.of(context).pop();
          });
        } else {
          _generalBottomSheet.showNoInternetBottomSheet(
            // TODO changes to refresh action
            context,
            () => Navigator.pop(context),
          );
        }
      };
    } else {
      return null;
    }
  }
}
