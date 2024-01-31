import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/main_page/main_page.dart';
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
            top: 12,
            left: 162,
            child: SizedBox(
              height: 95,
              width: 200,
              child: Image(
                fit: BoxFit.fill,
                image: AssetImage(ImagePath.quranImage),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 108,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                0,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          7.0,
                          0,
                          7.0,
                          5.0,
                        ),
                        child: Text(
                          'New! Habit Feature',
                          style: TextStyle(fontSize: 14, fontWeight: semiBold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 7.0),
                        width: 165,
                        child: Text(
                          'Build your reading habit by setting and tracking your daily goals',
                          style: TextStyle(
                            color: neutral700,
                            fontWeight: medium,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 10,
            child: ElevatedButton(
              onPressed: () {
                final navigationBar =
                    mainNavbarGlobalKey.currentWidget as BottomNavigationBar;
                print("lalalala");
                navigationBar.onTap!(1);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: primary500,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                elevation: 1,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: Text(
                  'Start Now',
                  style: TextStyle(fontSize: 12, fontWeight: semiBold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
