import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_v2.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_page.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_v2.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  static GlobalKey globalKey = GlobalKey<State<BottomNavigationBar>>();
  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  // Temporary value to include/exclude habit in build
  bool isHabitEnabled = true;

  final List<Widget> _pages = <Widget>[
    const HomePageV2(),
    // Only enable if `isHabitEnabled` true
    HabitPage(),
    const BookmarkPageV2(),
    SettingsPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        key: MainPage.globalKey,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          if (isHabitEnabled)
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(IconPath.iconChecklistCheck),
              ),
              label: 'Habit',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primary500,
        unselectedItemColor: neutral300,
        selectedFontSize: 12,
        onTap: (index) => onItemTapped(index),
      ),
    );
  }
}
