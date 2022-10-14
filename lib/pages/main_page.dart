import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_v2.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_page.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_v2.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePageV2(),
    const HabitPage(),
    const BookmarkPageV2(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("images/Icon_habit.png"),
            ),
            label: 'Habit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primary500,
        unselectedItemColor: neutral300,
        selectedFontSize: 12,
        onTap: _onItemTapped,
      ),
    );
  }
}
