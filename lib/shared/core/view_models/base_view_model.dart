import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseViewModel<T> extends StateNotifier<T> {
  BaseViewModel(T state) : super(state);

  bool _busy = false;
  bool get busy => _busy;

  dynamic initViewModel();

  void setBusy(bool value) {
    _busy = value;
  }
}
