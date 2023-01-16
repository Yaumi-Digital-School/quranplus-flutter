import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/services/authentication_service.dart';
import 'package:qurantafsir_flutter/shared/core/services/deep_link_service.dart';

class SplashPage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const SplashPage({required this.navigatorKey, Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _completer = Completer();

  startTime() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!_completer.isCompleted) {
        Navigator.of(context).pushReplacementNamed(RoutePaths.routeMain);
        _completer.complete();
      }
    });
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed(RoutePaths.routeMain);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  void dispose() {
    if (!_completer.isCompleted) {
      _completer.completeError('Cancelled');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final DeepLinkService deepLink = ref.watch(deepLinkService);
        deepLink.init(widget.navigatorKey);

        final AuthenticationService auth = ref.watch(authenticationService);
        auth.initRepository();

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
