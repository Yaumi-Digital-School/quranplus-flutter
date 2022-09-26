import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class GeneralSearchDialog {
  Future searchDialog(BuildContext context, Widget widgetChild) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brokenWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
          content: SizedBox(height: 205, width: 253, child: widgetChild),
        );
      },
    );
  }

  Future searchDialoggeneral(BuildContext context, Function function) {
    return searchDialog(
      context,
      Column(
        children: [
          const SizedBox(
            height: 5.0,
          ),
          Container(
            height: MediaQuery.of(context).size.height / 10,
            width: MediaQuery.of(context).size.width,
            child: Container(
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(6.0),
              primary: Colors.white,
              onPrimary: primary500,
              elevation: 2,
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () {
              function;
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  Future searchDialogWithTabbar(BuildContext context, List<String> tabBar,
      List<Widget> WidgetchildTabbarview) {
    return searchDialog(
      context,
      DefaultTabController(
        length: tabBar.length,
        child: Column(
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                  color: neutral100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: neutral300,
                      blurRadius: 9.0,
                      spreadRadius: 0.9,
                    )
                  ]),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(5.0),
                    height: 34,
                    child: TabBar(
                        unselectedLabelColor: primary500,
                        indicator: BoxDecoration(
                            color: primary500,
                            borderRadius: BorderRadius.circular(20)),
                        tabs: tabBar
                            .map((tabName) => Tab(child: Text(tabName)))
                            .toList()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 125,
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: WidgetchildTabbarview,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
