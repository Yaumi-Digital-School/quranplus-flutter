import 'package:flutter/widgets.dart';

class AliceService {
  AliceService(GlobalKey<NavigatorState> navigatorKey)
      : _navigatorKey = navigatorKey;

  // ignore: unused_field
  final GlobalKey<NavigatorState> _navigatorKey;

  void showInspector() {}
}
