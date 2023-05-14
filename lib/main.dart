import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:qurantafsir_flutter/pages/account_deletion/account_deletion_view.dart';
import 'package:qurantafsir_flutter/pages/habit_group_detail/habit_group_detail_view.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
import 'package:qurantafsir_flutter/pages/notification_reminder_page/notification_reminder_page.dart';
import 'package:qurantafsir_flutter/pages/prayer_time_page/prayer_time_page.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page.dart';
import 'package:qurantafsir_flutter/pages/splash_page/splash_page.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_story/tadabur_story_page.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_surah_list_page/tadabbur_surah_list_view.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/shared_preference_service.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/utils/geolocation_helper.dart';
import 'package:qurantafsir_flutter/shared/utils/notification_helper.dart';
import 'package:qurantafsir_flutter/shared/utils/worker_helper.dart';
import 'firebase_options.dart';
import 'pages/read_tadabbur/read_tadabbur_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails? notificationAppLaunchDetails;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final SharedPreferenceService sharedPreferenceService =
      SharedPreferenceService();
  await sharedPreferenceService.init();

  await initNotifications(flutterLocalNotificationsPlugin);
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  await initWorkerManager();

  await enablePeriodicTask(updatePrayerTimeTaskID, updatePrayerTimeTaskName,
      Duration(hours: 12), {'date': DateTime.now().toString()});

  await GlobalConfiguration().loadFromAsset('env');

  // Handle the notification launch details
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    // The app was opened via a notification
    final notificationPayload = notificationAppLaunchDetails!.payload;
    // Handle the notification payload here
  } else {
    // The app was opened via other means
    // Handle the app launch logic here
  }

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
    ref.read(aliceServiceProvider).init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        primarySwatch: Colors.blue,
        backgroundColor: backgroundColor,
        scaffoldBackgroundColor: QPColors.whiteFair,
      ),
      navigatorObservers: <NavigatorObserver>[MyApp.observer],
      navigatorKey: navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        late Widget selectedRouteWidget;
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
          case RoutePaths.routeSetupPrayerTime:
            selectedRouteWidget = PrayerTimePage();
            break;
          case RoutePaths.routeNotificationSetting:
            selectedRouteWidget = NotificationReminderPage();
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
