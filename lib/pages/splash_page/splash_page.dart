import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/splash_page/splash_page_state_notifier.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';

class SplashPage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const SplashPage({required this.navigatorKey, Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<SplashPageStateNotifier, SplashPageState>(
      stateNotifierProvider:
          StateNotifierProvider<SplashPageStateNotifier, SplashPageState>(
        (ref) {
          return SplashPageStateNotifier(
            deepLinkService: ref.watch(deepLinkService),
            authenticationService: ref.watch(authenticationService),
            navigatorKey: widget.navigatorKey,
            tadabburService: ref.read(tadabburService),
            remoteConfigService: ref.read(remoteConfigService),
          );
        },
      ),
      onStateNotifierReady: (notifier, _) async {
        await Future.delayed(const Duration(milliseconds: 2500), () async {
          await notifier.initStateNotifier();
          Navigator.of(context).pushReplacementNamed(RoutePaths.routeMain);
        });
      },
      builder: (
        _,
        SplashPageState state,
        SplashPageStateNotifier notifier,
        __,
      ) {
        return Scaffold(
          body: Center(
            child: Container(
              width: 92,
              height: 110,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    ImagePath.logoQuranPlusPotrait,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
