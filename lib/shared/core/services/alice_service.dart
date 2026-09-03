import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:flutter/widgets.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';

class AliceService {
  AliceService(GlobalKey<NavigatorState> navigatorKey) {
    // The HTTP inspector (and its shake-to-open handler) must never exist in
    // production. Building Alice only for non-production keeps the whole tool —
    // adapter, inspector, shake listener — inert when it should be off.
    if (!EnvConstants.isProduction) {
      final Alice createdAlice = Alice(
        configuration: AliceConfiguration(
          navigatorKey: navigatorKey,
          showNotification: false,
          showInspectorOnShake: true,
        ),
      );
      final AliceDioAdapter createdAdapter = AliceDioAdapter();
      createdAlice.addAdapter(createdAdapter);

      alice = createdAlice;
      dioAdapter = createdAdapter;
    }
  }

  Alice? alice;
  AliceDioAdapter? dioAdapter;

  void showInspector() => alice?.showInspector();
}
