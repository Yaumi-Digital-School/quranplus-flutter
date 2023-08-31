import 'package:alice/alice.dart';
import 'package:flutter/widgets.dart';

class AliceService {
  AliceService(GlobalKey<NavigatorState> navigatorKey)
      : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;

  Alice get alice => Alice(
        navigatorKey: _navigatorKey,
        showNotification: false,
        showInspectorOnShake: true,
      );
}
