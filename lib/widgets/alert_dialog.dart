import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/search_by_page_or_ayah.dart';

class GeneralSearchDialog {
  static Future searchDialog(BuildContext context, Widget widgetChild) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brokenWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(19)),
          ),
          content: SizedBox(
            height: 205,
            width: 253,
            child: widgetChild,
          ),
        );
      },
    );
  }

  static Future searchDialogGeneral(BuildContext context, Function() function) {
    return searchDialog(
      context,
      Column(
        children: [
          const SizedBox(
            height: 5.0,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 10,
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 3 / 7,
              child: const TextField(
                enabled: true,
                decoration: InputDecoration(hintText: '1', labelText: 'Surah'),
              ),
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
          ButtonSecondary(
            label: 'Search',
            onTap: function,
          ),
        ],
      ),
    );
  }

  static Future<void> searchDialogByPageOrAyah(
    BuildContext context,
    Map<String, List<String>> verseMapper,
  ) {
    return searchDialog(
      context,
      SearchByPageOrAyah(
        verseMapper: verseMapper,
      ),
    );
  }

  static Future searchDialogWithTabbar(
    BuildContext context,
    List<String> tabBar,
    List<Widget> widgetChildTabBarView,
  ) {
    return searchDialog(
      context,
      DefaultTabController(
        length: tabBar.length,
        child: Column(
          children: [
            Container(
              height: 44,
              decoration: const BoxDecoration(
                color: neutral100,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: neutral300,
                    blurRadius: 9.0,
                    spreadRadius: 0.9,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    height: 34,
                    child: TabBar(
                      unselectedLabelColor: primary500,
                      indicator: const BoxDecoration(
                        color: primary500,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      tabs: tabBar
                          .map((tabName) => Tab(child: Text(tabName)))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 125,
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: widgetChildTabBarView,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Alert {
  static Future searchDialog(BuildContext context, Widget widgetChild) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brokenWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
          content: SizedBox(
            height: 245,
            width: 321,
            child: widgetChild,
          ),
        );
      },
    );
  }
}
