import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/account_page/account_page_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/account_page/widgets/date_of_birth_picker.dart';
import 'package:qurantafsir_flutter/pages/account_page/widgets/gender_selector.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:qurantafsir_flutter/shared/utils/form_status.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountPageProvider);
    final notifier = ref.read(accountPageProvider.notifier);
    final connectivityStatus = ref.watch(internetConnectionStatusProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54.0),
        child: AppBar(
          elevation: 0.7,
          foregroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: const Text(
            'Account',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
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
                style: QPTextStyle.getSubHeading2SemiBold(context),
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
                style: QPTextStyle.getSubHeading3Medium(context),
                onChanged: (value) {
                  notifier.nameChanged(value);
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  hintText: 'Name',
                  hintStyle: QPTextStyle.getSubHeading3Medium(context)
                      .copyWith(color: Theme.of(context).hintColor),
                  border: enabledInputBorder,
                  enabledBorder: enabledInputBorder,
                  errorBorder: errorInputBorder,
                  focusedErrorBorder: errorInputBorder,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Email',
                style: QPTextStyle.getSubHeading2SemiBold(context),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: state.email),
                style: QPTextStyle.getSubHeading3Medium(context),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  enabled: false,
                  contentPadding: const EdgeInsets.all(8),
                  hintText: 'email@gmail.com',
                  hintStyle: QPTextStyle.getSubHeading3Medium(context)
                      .copyWith(color: Theme.of(context).hintColor),
                  border: enabledInputBorder,
                  enabledBorder: enabledInputBorder,
                  fillColor: QPColors.getColorBasedTheme(
                    dark: QPColors.blackFair,
                    light: QPColors.whiteRoot,
                    brown: QPColors.brownModeHeavy,
                    context: context,
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Please complete the fields below',
                style: QPTextStyle.getSubHeading3Regular(context),
              ),
              const SizedBox(height: 16),
              DateOfBirthPicker(
                day: state.dateOfMonth,
                month: state.month,
                year: state.year,
                hasError: state.formStatus == FormStatus.invalid &&
                    (state.dateOfMonth.isEmpty ||
                        state.month.isEmpty ||
                        state.year.isEmpty),
                onDayChanged: notifier.dateOfMonthChanged,
                onMonthChanged: notifier.monthChanged,
                onYearChanged: notifier.yearChanged,
              ),
              const SizedBox(height: 24),
              GenderSelector(
                selectedGenderInitial: state.gender,
                hasError: state.formStatus == FormStatus.invalid &&
                    state.gender.isEmpty,
                onChanged: notifier.genderChanged,
              ),
              const SizedBox(height: 48),
              ButtonSecondary(
                label: 'Save',
                onTap: _onPressedButtonSave(
                  state.formStatus,
                  context,
                  ref,
                  connectivityStatus,
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
  }

  _onPressedButtonSave(
    FormStatus formStatus,
    BuildContext context,
    WidgetRef ref,
    ConnectivityStatus connectivityStatus,
  ) {
    if (formStatus == FormStatus.valid) {
      return () async {
        if (connectivityStatus == ConnectivityStatus.isConnected) {
          ref.read(accountPageProvider.notifier).saveButtonChecked(() {
            Navigator.of(context).pop();
          });
        } else if (context.mounted) {
          GeneralBottomSheet.showNoInternetBottomSheet(
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
