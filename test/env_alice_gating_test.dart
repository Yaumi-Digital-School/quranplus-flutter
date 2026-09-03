// Tests for gating the Alice HTTP inspector behind the `environment` config
// value. The fail-safe rule is the crux: a missing/unknown environment must
// resolve to production (inspector OFF), so a config mistake can never ship the
// inspector enabled.
//
// GlobalConfiguration is a process-wide singleton, so each test clears and
// re-seeds it.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/services/alice_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void seedEnvironment(String? environment) {
    GlobalConfiguration().clear();
    final Map<String, dynamic> map = <String, dynamic>{
      'baseUrl': 'https://example.test',
    };
    if (environment != null) {
      map['environment'] = environment;
    }
    GlobalConfiguration().loadFromMap(map);
  }

  tearDown(() {
    GlobalConfiguration().clear();
  });

  group('EnvConstants.isProduction', () {
    test('environment "production" -> isProduction true', () {
      seedEnvironment('production');
      expect(EnvConstants.environment, 'production');
      expect(EnvConstants.isProduction, isTrue);
    });

    test('production check is case-insensitive', () {
      seedEnvironment('Production');
      expect(EnvConstants.isProduction, isTrue);
    });

    test('environment "development" -> isProduction false', () {
      seedEnvironment('development');
      expect(EnvConstants.isProduction, isFalse);
    });

    test('environment "staging" -> isProduction false', () {
      seedEnvironment('staging');
      expect(EnvConstants.isProduction, isFalse);
    });

    test('missing environment key -> isProduction true (fail-safe)', () {
      seedEnvironment(null);
      expect(EnvConstants.environment, isNull);
      expect(EnvConstants.isProduction, isTrue);
    });
  });

  group('AliceService gating', () {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    test(
      'production config -> inert (null alice/dioAdapter, no-op inspector)',
      () {
        seedEnvironment('production');
        final AliceService service = AliceService(navigatorKey);

        expect(service.alice, isNull);
        expect(service.dioAdapter, isNull);
        expect(service.showInspector, returnsNormally);
      },
    );

    test('non-production config -> Alice + adapter are created', () {
      seedEnvironment('development');
      final AliceService service = AliceService(navigatorKey);

      expect(service.alice, isNotNull);
      expect(service.dioAdapter, isNotNull);
    });
  });
}
