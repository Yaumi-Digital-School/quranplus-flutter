import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';
import 'package:qurantafsir_flutter/shared/core/models/user.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/base_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/utils/form_status.dart';
import 'package:qurantafsir_flutter/shared/utils/result_status.dart';

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

class AccountPageStateNotifier extends BaseStateNotifier<AccountPageState> {
  AccountPageStateNotifier({
    required AuthenticationService repository,
    required SharedPreferenceService sharedPreferenceService,
  })  : _repository = repository,
        _sharedPreferenceService = sharedPreferenceService,
        super(AccountPageState());

  final AuthenticationService _repository;
  final SharedPreferenceService _sharedPreferenceService;
  late String _token;

  @override
  Future<void> initStateNotifier() async {
    var token = _sharedPreferenceService.getApiToken();
    _token = token;
    _getUserProfile();
  }

  void nameChanged(name) async {
    FormStatus status = FormStatus.dirty;
    var valid = _checkValidation(
      name,
      state.email,
      _isDate(state.dateOfMonth, state.month, state.year),
      state.gender,
    );

    if (valid) {
      status = FormStatus.valid;
    }

    state = state.copyWith(formStatus: status, name: name);
  }

  void genderChanged(gender) async {
    FormStatus status = FormStatus.dirty;
    var valid = _checkValidation(
      state.name,
      state.email,
      _isDate(state.dateOfMonth, state.month, state.year),
      gender,
    );

    if (valid) {
      status = FormStatus.valid;
    }

    state = state.copyWith(formStatus: status, gender: gender);
  }

  void dateOfMonthChanged(String dateOfMonth) async {
    FormStatus status = FormStatus.dirty;
    var valid = _checkValidation(
      state.name,
      state.email,
      _isDate(dateOfMonth, state.month, state.year),
      state.gender,
    );

    if (valid) {
      status = FormStatus.valid;
    }

    state = state.copyWith(formStatus: status, dateOfMonth: dateOfMonth);
  }

  void monthChanged(String month) async {
    FormStatus status = FormStatus.dirty;
    var newMonth = month.length == 1 ? '0$month' : month;

    var valid = _checkValidation(
      state.name,
      state.email,
      _isDate(state.dateOfMonth, newMonth, state.year),
      state.gender,
    );

    if (valid) {
      status = FormStatus.valid;
    }

    state = state.copyWith(formStatus: status, month: month);
  }

  void yearChanged(String year) async {
    if (year.length == 4) {
      FormStatus status = FormStatus.dirty;

      if (int.parse(year) < 1900) {
        year = '1900';
      }

      var valid = _checkValidation(
        state.name,
        state.email,
        _isDate(state.dateOfMonth, state.month, year),
        state.gender,
      );

      if (valid) {
        status = FormStatus.valid;
      }

      state = state.copyWith(formStatus: status, year: year);
    } else if (year.isEmpty) {
      state = state.copyWith(year: '');
    }
  }

  void saveButtonChecked(Function() callback) async {
    var valid = state.name.isNotEmpty &&
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
      var formattedDate =
          DateFormat('d-M-yyyy').parseStrict('$dateOfMonth-$month-$year');

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

  bool _checkValidation(
    String name,
    String email,
    String date,
    String gender,
  ) {
    return ((name.isNotEmpty && email.isNotEmpty) ||
        date.isNotEmpty ||
        gender.isNotEmpty);
  }

  Future<void> _getUserProfile() async {
    state = state.copyWith(resultStatus: ResultStatus.inProgress);

    try {
      var user = await _repository.getUserProfile(_token);

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

    var user = User(
      name: state.name,
      email: state.email,
      birthDate: _isDate(state.dateOfMonth, state.month, state.year),
      gender: state.gender,
    );

    try {
      var isSuccess = await _repository.updateUserProfile(_token, user);

      if (isSuccess) {
        state = state.copyWith(resultStatus: ResultStatus.success);
        _setUsername(state.name);
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

  Future<void> _setUsername(String name) async {
    await _sharedPreferenceService.setUsername(name);
  }
}
