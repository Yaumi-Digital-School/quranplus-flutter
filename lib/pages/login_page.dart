import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/home_page.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign in to',
              style: bodyMedium3,
            ),
            SizedBox(height: defaultMargin),
            Container(
              width: 130,
              height: 48,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                'images/logo.png',
              ))),
            ),
            SizedBox(height: defaultMargin),
            SizedBox(
              height: 38.0,
              width: 270.0,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(24.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          offset: Offset(1.0, 2.0),
                          blurRadius: 5.0,
                          spreadRadius: 1.0)
                    ]),
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('images/icon_google.png',
                              width: 24, height: 24),
                          const SizedBox(width: 16.0),
                          Text("Sign in with Google",
                              style: buttonMedium1.copyWith(color: primary500)),
                        ],
                      ),
                    ),
                    SizedBox.expand(
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const HomePage();
                          }));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
