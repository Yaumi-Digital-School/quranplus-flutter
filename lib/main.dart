import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:qurantafsir_flutter/pages/main_page.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page.dart';
import 'package:qurantafsir_flutter/pages/splash_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final SharedPreferenceService sharedPreferenceService =
      SharedPreferenceService();
  await sharedPreferenceService.init();

  await GlobalConfiguration().loadFromAsset('env');

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferenceServiceProvider.overrideWithValue(
          sharedPreferenceService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final SharedPreferenceService sp =
            ref.watch(sharedPreferenceServiceProvider);
        final AuthenticationService ur = ref.watch(authenticationService);
        if (sp.getApiToken().isNotEmpty) {
          ur.setIsLoggedIn(true);
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: ThemeData(
              primarySwatch: Colors.blue, backgroundColor: backgroundColor),
          navigatorObservers: <NavigatorObserver>[observer],
          onGenerateRoute: (RouteSettings settings) {
            late Widget selectedRouteWidget;
            switch (settings.name) {
              case RoutePaths.routeSplash:
                selectedRouteWidget = const SplashPage();
                break;
              case RoutePaths.routeMain:
                selectedRouteWidget = const MainPage();
                break;
              case RoutePaths.routeSettings:
                selectedRouteWidget = SettingsPage();
                break;
              case RoutePaths.routeSurahPage:
                final args = settings.arguments is SuratPageV3Param
                    ? settings.arguments as SuratPageV3Param
                    : SuratPageV3Param(startPageInIndex: 0);
                selectedRouteWidget = SuratPageV3(param: args);
                break;
              default:
                selectedRouteWidget = const Scaffold(
                  body: Center(
                    child: Text('No route defined'),
                  ),
                );
            }

            return MaterialPageRoute(
              builder: (context) {
                return selectedRouteWidget;
              },
            );
          },
        );
      },
    );
  }
}
