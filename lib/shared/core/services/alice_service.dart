import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:flutter/widgets.dart';

class AliceService {
  AliceService(GlobalKey<NavigatorState> navigatorKey)
      : alice = Alice(
          configuration: AliceConfiguration(
            navigatorKey: navigatorKey,
            showNotification: false,
            showInspectorOnShake: true,
          ),
        ) {
    alice.addAdapter(dioAdapter);
  }

  final Alice alice;
  final AliceDioAdapter dioAdapter = AliceDioAdapter();

  void showInspector() => alice.showInspector();
}
