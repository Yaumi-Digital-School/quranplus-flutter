import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/pages/bookmark_v2/bookmark_page_v2.dart';
import 'package:qurantafsir_flutter/pages/habit_page/habit_page.dart';
import 'package:qurantafsir_flutter/pages/home_page_v2/home_page_v2.dart';
import 'package:qurantafsir_flutter/pages/settings_page/settings_page.dart';
import 'package:qurantafsir_flutter/pages/tadabbur_surah_list_page/tadabbur_surah_list_view.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';

class MainPageParam {
  MainPageParam({
    this.initialSelectedIdx = 0,
  });

  final int initialSelectedIdx;
}

GlobalKey mainNavbarGlobalKey = GlobalKey<State<BottomNavigationBar>>();

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
    this.param,
  }) : super(key: key);

  final MainPageParam? param;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;

  final List<Widget> _pages = <Widget>[
    const HomePageV2(),
    const HabitPage(),
    const TadabburSurahListView(),
    const BookmarkPageV2(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    _selectedIndex = 0;
    if (widget.param?.initialSelectedIdx != null) {
      _selectedIndex = widget.param!.initialSelectedIdx;
    }

    super.initState();
  }

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
        key: mainNavbarGlobalKey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: QPColors.getColorBasedTheme(
          dark: QPColors.darkModeHeavy,
          light: QPColors.whiteMassive,
          brown: QPColors.brownModeFair,
          context: context,
        ),
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage(
                StoredIcon.iconHabitArrow.path,
              ),
            ),
            label: 'Habit',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Tadabbur',
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
        selectedItemColor: QPColors.brandFair,
        unselectedItemColor: QPColors.getColorBasedTheme(
          dark: QPColors.whiteFair,
          light: QPColors.blackFair,
          brown: QPColors.brownModeMassive,
          context: context,
        ),
        selectedFontSize: 12,
        onTap: (index) => onItemTapped(index),
      ),
    );
  }
}
