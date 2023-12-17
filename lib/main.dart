import 'package:audio_service/audio_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:qurantafsir_flutter/pages/account_deletion/account_deletion_view.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_view.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/prayer_time.dart';
import 'package:qurantafsir_flutter/pages/registration_and_login_page/registration_and_login_page.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page.dart';
import 'package:qurantafsir_flutter/pages/splash_page/splash_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/tadabur_story_page.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_surah_list_page/tadabbur_surah_list_view.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qurantafsir_flutter/shared/core/providers/audio_provider.dart';
import 'package:qurantafsir_flutter/shared/core/services/alice_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/audio_recitation/audio_recitation_handler.dart';
import 'firebase_options.dart';
import 'pages/read_tadabbur/read_tadabbur_page.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final SharedPreferenceService sharedPreferenceService =
      SharedPreferenceService();
  await sharedPreferenceService.init();

  final AudioRecitationHandler currentAudioHandler =
      await AudioService.init<AudioRecitationHandler>(
    builder: () => AudioRecitationHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.yaumi.qurantafsir.id',
      androidNotificationChannelName: 'Quran Plus',
      androidStopForegroundOnPause: true,
    ),
  );

  await GlobalConfiguration().loadFromAsset('env');

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

    return true;
  };
  runApp(
    ProviderScope(
      overrides: [
        audioHandler.overrideWithValue(
          currentAudioHandler,
        ),
        sharedPreferenceServiceProvider.overrideWithValue(
          sharedPreferenceService,
        ),
        aliceServiceProvider.overrideWithValue(AliceService(navigatorKey)),
      ],
      child: const MyApp(),
    ),
  );

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;

    return stack;
  };
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeProvider.notifier).initStateNotifier();
    });

    super.initState();
  }

  ThemeData _getThemeData(QPThemeMode theme) {
    switch (theme) {
      case QPThemeMode.brown:
        return QPThemeData.brownThemeData;
      case QPThemeMode.dark:
        return QPThemeData.darkThemeData;
      default:
        return QPThemeData.lightThemeData;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SharedPreferenceService sp =
        ref.watch(sharedPreferenceServiceProvider);
    final AuthenticationService ur = ref.watch(authenticationService);

    final mode = ref.watch(themeProvider);
    if (sp.getApiToken().isNotEmpty) {
      ur.setIsLoggedIn(true);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: _getThemeData(mode),
      navigatorObservers: <NavigatorObserver>[MyApp.observer],
      navigatorKey: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        late Widget selectedRouteWidget;
        print(settings.name);
        switch (settings.name) {
          case RoutePaths.routeSplash:
            selectedRouteWidget = SplashPage(navigatorKey: navigatorKey);
            break;
          case RoutePaths.routeMain:
            final args = settings.arguments != null &&
                    settings.arguments is MainPageParam
                ? settings.arguments as MainPageParam
                : null;
            selectedRouteWidget = MainPage(
              param: args,
            );
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
          case RoutePaths.routeHabitGroupDetail:
            final args = settings.arguments is HabitGroupDetailViewParam
                ? settings.arguments as HabitGroupDetailViewParam
                : HabitGroupDetailViewParam(id: 0);
            selectedRouteWidget = HabitGroupDetailView(param: args);
            break;
          case RoutePaths.accountDeletion:
            selectedRouteWidget = const AccountDeletionInformationView();
            break;
          case RoutePaths.tadabburSurahList:
            selectedRouteWidget = const TadabburSurahListView();
            break;
          case RoutePaths.routeReadTadabbur:
            final args = settings.arguments is ReadTadabburParam
                ? settings.arguments as ReadTadabburParam
                : ReadTadabburParam(surahName: "", surahId: 0);
            selectedRouteWidget = ReadTadabburPage(
              param: args,
            );
            break;
          case RoutePaths.routeTadabburContent:
            final args = settings.arguments as TadabburStoryPageParams;
            selectedRouteWidget = TadabburStoryPage(
              params: args,
            );
            break;
          case RoutePaths.routeLogin:
            final args = settings.arguments as RegistrationAndLoginPageParam;
            selectedRouteWidget = RegistrationAndLoginPage(
              param: args,
            );
            break;
          case RoutePaths.routePrayerTimePage:
            print("object");
            selectedRouteWidget = PrayerTimePage();
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
  }
}
