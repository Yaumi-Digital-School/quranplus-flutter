import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseStateNotifier<T> extends StateNotifier<T> {
  BaseStateNotifier(T state) : super(state);

  dynamic initStateNotifier();
}
