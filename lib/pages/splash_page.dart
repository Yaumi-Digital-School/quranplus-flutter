import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/route_paths.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  startTime() async {
    var _duration = const Duration(milliseconds: 2500);
    return Timer(_duration, navigationPage);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 130,
          height: 48,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
            'images/logo.png',
          ))),
        ),
      ),
    );
  }
}
