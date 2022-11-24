import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/main_page.dart';
import 'package:qurantafsir_flutter/shared/constants/image.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class StartHabitCard extends StatelessWidget {
  const StartHabitCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: primary200,
      elevation: 1.2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 162,
            child: SizedBox(
              width: 210,
              height: 130,
              child: Image(
                fit: BoxFit.fill,
                image: AssetImage(ImagePath.quranImage),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 140,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 17, 12, 7),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(7.0, 7.0, 7.0, 6.0),
                        child: Text(
                          'New! Habit Feature',
                          style: TextStyle(fontSize: 15, fontWeight: semiBold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 7.0),
                        width: 210,
                        child: Text(
                          'Build your reading habit by set  and track your daily goals',
                          style:
                              TextStyle(color: neutral500, fontWeight: regular),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final navigationBar = MainPage.globalKey.currentWidget
                              as BottomNavigationBar;

                          navigationBar.onTap!(1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Text(
                            'Start Now',
                            style:
                                TextStyle(fontSize: 12, fontWeight: semiBold),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          primary: Colors.white,
                          onPrimary: primary500,
                          elevation: 1,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
