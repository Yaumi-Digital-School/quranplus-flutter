import 'package:alice/alice.dart';
import 'package:flutter/widgets.dart';

class AliceService {
  AliceService(GlobalKey<NavigatorState> navigatorKey)
      : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;
  late Alice _alice;

  void init() {
    _alice = Alice(
      navigatorKey: _navigatorKey,
      showNotification: false,
      showInspectorOnShake: false,
    );
  }

  Alice get alice => _alice;
}
