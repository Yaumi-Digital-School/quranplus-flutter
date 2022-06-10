import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/home_page.dart';
import 'package:qurantafsir_flutter/pages/main_page.dart';
import 'package:qurantafsir_flutter/pages/splash_page.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: ThemeData(
            primarySwatch: Colors.blue, backgroundColor: backgroundColor),
        initialRoute: AppConstants.routeSplash,
        navigatorObservers: <NavigatorObserver>[observer],
        routes: {
          AppConstants.routeSplash: (context) => const SplashPage(),
          AppConstants.routeMain: (context) => const MainPage()
        },
      ),
    );
  }
}
