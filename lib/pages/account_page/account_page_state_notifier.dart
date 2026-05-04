import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/utils/form_status.dart';
import 'package:qurantafsir_flutter/shared/utils/result_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_page_state_notifier.g.dart';

class AccountPageState {
  AccountPageState({
    this.resultStatus = ResultStatus.pure,
    this.formStatus = FormStatus.pure,
    this.name = '',
    this.email = '',
    this.dateOfMonth = '',
    this.month = '',
    this.year = '',
    this.gender = '',
  });

  ResultStatus resultStatus;
  FormStatus formStatus;
  String name;
  String email;
  String dateOfMonth;
  String month;
  String year;
  String gender;

  AccountPageState copyWith({
    ResultStatus? resultStatus,
    FormStatus? formStatus,
    String? name,
    String? email,
    String? dateOfMonth,
    String? month,
    String? year,
    String? gender,
  }) {
    return AccountPageState(
      resultStatus: resultStatus ?? this.resultStatus,
      formStatus: formStatus ?? this.formStatus,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfMonth: dateOfMonth ?? this.dateOfMonth,
      month: month ?? this.month,
      year: year ?? this.year,
      gender: gender ?? this.gender,
    );
  }
}

@riverpod
class AccountPageNotifier extends _$AccountPageNotifier {
  late String _token;

  @override
  AccountPageState build() {
    _token = ref.read(sharedPreferenceServiceProvider).getApiToken();
    Future.microtask(_getUserProfile);
    return AccountPageState();
  }

  void nameChanged(name) {
    final status =
        _checkValidation(
          name,
          state.email,
          _isDate(state.dateOfMonth, state.month, state.year),
          state.gender,
        )
        ? FormStatus.valid
        : FormStatus.dirty;
    state = state.copyWith(formStatus: status, name: name);
  }

  void genderChanged(gender) {
    final status =
        _checkValidation(
          state.name,
          state.email,
          _isDate(state.dateOfMonth, state.month, state.year),
          gender,
        )
        ? FormStatus.valid
        : FormStatus.dirty;
    state = state.copyWith(formStatus: status, gender: gender);
  }

  void dateOfMonthChanged(String dateOfMonth) {
    final status =
        _checkValidation(
          state.name,
          state.email,
          _isDate(dateOfMonth, state.month, state.year),
          state.gender,
        )
        ? FormStatus.valid
        : FormStatus.dirty;
    state = state.copyWith(formStatus: status, dateOfMonth: dateOfMonth);
  }

  void monthChanged(String month) {
    final newMonth = month.length == 1 ? '0$month' : month;
    final status =
        _checkValidation(
          state.name,
          state.email,
          _isDate(state.dateOfMonth, newMonth, state.year),
          state.gender,
        )
        ? FormStatus.valid
        : FormStatus.dirty;
    state = state.copyWith(formStatus: status, month: month);
  }

  void yearChanged(String year) {
    if (year.length == 4) {
      if (int.parse(year) < 1900) year = '1900';
      final status =
          _checkValidation(
            state.name,
            state.email,
            _isDate(state.dateOfMonth, state.month, year),
            state.gender,
          )
          ? FormStatus.valid
          : FormStatus.dirty;
      state = state.copyWith(formStatus: status, year: year);
    } else if (year.isEmpty) {
      state = state.copyWith(year: '');
    }
  }

  void saveButtonChecked(Function() callback) async {
    final valid =
        state.name.isNotEmpty &&
        state.email.isNotEmpty &&
        _isDate(state.dateOfMonth, state.month, state.year).isNotEmpty &&
        state.gender.isNotEmpty;
    if (!valid) {
      state = state.copyWith(formStatus: FormStatus.invalid);
    } else {
      await _updateUserProfile();
      callback.call();
    }
  }

  String _isDate(String dateOfMonth, String month, String year) {
    try {
      final formattedDate = DateFormat(
        'd-M-yyyy',
      ).parseStrict('$dateOfMonth-$month-$year');
      return formattedDate.toString();
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _isDate() method',
      );
      return '';
    }
  }

  bool _checkValidation(String name, String email, String date, String gender) {
    return ((name.isNotEmpty && email.isNotEmpty) ||
        date.isNotEmpty ||
        gender.isNotEmpty);
  }

  Future<void> _getUserProfile() async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);
    try {
      final user = await ref.read(authenticationService).getUserProfile(_token);
      state = state.copyWith(
        resultStatus: ResultStatus.success,
        formStatus: FormStatus.pure,
        name: user.name.isNotEmpty ? user.name : '',
        email: user.email.isNotEmpty ? user.email : '',
        dateOfMonth: user.birthDate.isNotEmpty
            ? DateFormat('dd').format(DateTime.parse(user.birthDate))
            : '',
        month: user.birthDate.isNotEmpty
            ? DateFormat('MM').format(DateTime.parse(user.birthDate))
            : '',
        year: user.birthDate.isNotEmpty
            ? DateFormat('yyyy').format(DateTime.parse(user.birthDate))
            : '',
        gender: user.gender.isNotEmpty ? user.gender : '',
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _getUserProfile() method',
      );
      state = state.copyWith(resultStatus: ResultStatus.failure);
    }
  }

  Future<void> _updateUserProfile() async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);
    final user = User(
      name: state.name,
      email: state.email,
      birthDate: _isDate(state.dateOfMonth, state.month, state.year),
      gender: state.gender,
    );
    try {
      final isSuccess = await ref
          .read(authenticationService)
          .updateUserProfile(_token, user);
      if (isSuccess) {
        state = state.copyWith(resultStatus: ResultStatus.success);
        await ref.read(sharedPreferenceServiceProvider).setUsername(state.name);
      } else {
        state = state.copyWith(resultStatus: ResultStatus.failure);
      }
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'error on _updateUserProfile() method',
      );
      state = state.copyWith(resultStatus: ResultStatus.failure);
    }
  }
}
