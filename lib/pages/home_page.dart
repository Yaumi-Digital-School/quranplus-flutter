import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Widget header(){
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'images/icon_home.png',
                      )
                    )
                  ),
                ),
                const SizedBox(
                  width: 18,
                ),
                Container(
                  width: 65,
                  height: 24,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'images/logo.png',
                      )
                    )
                  ),
                ),
              ],
            ),
            OutlinedButton(
              onPressed: (){
    
              }, 
              child: const Text('Sign In', style: TextStyle(color: primary500),)
              
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: defaultMargin),
        child: Column(
          children: [
            header()
          ],
        ),
      ),
    );
  }
}
