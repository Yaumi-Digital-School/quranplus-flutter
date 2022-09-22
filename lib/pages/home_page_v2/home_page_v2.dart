import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/shared/constants/app_constants.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/env.dart';
import 'package:qurantafsir_flutter/shared/core/models/form.dart';
import 'package:qurantafsir_flutter/shared/core/models/juz.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/ui/state_notifier_connector.dart';
import 'package:qurantafsir_flutter/widgets/searchDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../surat_page_v3/utils.dart';
import 'home_page_state_notifier.dart';

StateNotifierProvider<HomePageStateNotifier, HomePageState>
    homePageStateNotifier =
    StateNotifierProvider<HomePageStateNotifier, HomePageState>(
  (ref) {
    return HomePageStateNotifier(
      sharedPreferenceService: ref.watch(sharedPreferenceServiceProvider),
    );
  },
);

class HomePageV2 extends StatelessWidget {
  const HomePageV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierConnector<HomePageStateNotifier, HomePageState>(
      stateNotifierProvider: homePageStateNotifier,
      onStateNotifierReady: (notifier) async {
        await notifier.initStateNotifier();
      },
      builder: (
        BuildContext context,
        HomePageState state,
        HomePageStateNotifier notifier,
        _,
      ) {
        if (state.juzElements == null || state.feedbackUrl == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0.5,
              centerTitle: false,
              foregroundColor: primary500,
              title: Transform.translate(
                offset: const Offset(8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 65,
                      height: 24,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'images/logo.png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: IconButton(
                        onPressed: () => _launchUrl(state.feedbackUrl),
                        icon: Image.asset(
                          'images/icon_form.png',
                        ),
                      ),
                    )
                  ],
                ),
              ),
              backgroundColor: backgroundColor,
            ),
          ),
          body: const ListSuratByJuz(),
        );
      },
    );
  }

  Future<void> _launchUrl(String? url) async {
    final Uri _url = Uri.parse(url ?? '');
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }
}

class ListSuratByJuz extends StatelessWidget {
  const ListSuratByJuz({Key? key}) : super(key: key);
  double diameterButtonSearch(BuildContext context) =>
      MediaQuery.of(context).size.width * 1 / 6;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        HomePageState state = ref.watch(homePageStateNotifier);
        return Stack(
          children: <Widget>[
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: backgroundColor,
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 15,
                          offset: Offset(4, 4))
                    ],
                  ),
                  child: Text(
                    state.name.isNotEmpty
                        ? 'Assalamu’alaikum, ${state.name}'
                        : 'Assalamu’alaikum',
                    textAlign: TextAlign.start,
                    style: captionSemiBold1,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.juzElements!.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: <Widget>[
                          Container(
                            height: 42,
                            alignment: Alignment.centerLeft,
                            decoration: const BoxDecoration(color: neutral200),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              state.juzElements![index].name,
                              textAlign: TextAlign.start,
                              style: bodyRegular1,
                            ),
                          ),
                          _buildListSuratByJuz(
                              context, state.juzElements![index]),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: diameterButtonSearch(context) * 2 / 6,
              right: diameterButtonSearch(context) * 2 / 6,
              child: Container(
                width: diameterButtonSearch(context),
                height: diameterButtonSearch(context),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: darkGreen),
                child: ButtonSearch(
                  key: key,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildListSuratByJuz(BuildContext context, JuzElement juz) {
    final List<SuratByJuz> surats = juz.surat;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: surats.length,
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: backgroundColor,
            minLeadingWidth: 20,
            leading: Container(
              alignment: Alignment.center,
              height: 34,
              width: 30,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(1.0, 2.0),
                        blurRadius: 5.0,
                        spreadRadius: 1.0)
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Text(
                surats[index].number,
                style: numberStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            title: Text(
              surats[index].nameLatin,
              style: bodyMedium2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "Page ${surats[index].startPage}, Ayat ${surats[index].startAyat}",
              style: bodyLight3,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              surats[index].name,
              style: suratFontStyle,
              textAlign: TextAlign.right,
            ),
            onTap: () {
              int page = surats[index].startPageToInt;
              int startPageInIndexValue = page - 1;

              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: SuratPageV3(
                    startPageInIndex: startPageInIndexValue,
                    firstPagePointerIndex: surats[index].hashKey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String PageData = '';

class ButtonSearch extends StatelessWidget {
  ButtonSearch({Key? key}) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    List<String> TabbarTabs = ['Page', 'Ayah'];
    List<Widget> WidgetTabbarviewChildren = [
      tabviewSearchPage(context),
      tabviewSearchSurahandAyah(context)
    ];

    final GeneralSearchDialog _generalSearchDialog = GeneralSearchDialog();
    return IconButton(
        onPressed: () => _generalSearchDialog.searchDialogWithTabbar(
            context, TabbarTabs, WidgetTabbarviewChildren),
        icon: const Icon(
          Icons.search_outlined,
          size: 37.0,
          color: neutral100,
        ));
  }
}

Widget _dropdownSuggestionSearchPage(BuildContext context) {
  List<String> _numberPageString =
      Numberpage().map((el) => el.toString()).toList();

  return RawAutocomplete<String>(
    optionsBuilder: (TextEditingValue textEditingValue) {
      return _numberPageString.where((String option) {
        return option.contains(textEditingValue.text.toLowerCase());
      });
    },
    fieldViewBuilder: (BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted) {
      return TextFormField(
        controller: textEditingController,
        focusNode: focusNode,
        onFieldSubmitted: (String value) {
          onFieldSubmitted();
        },
        onChanged: (String page) {
          PageData = page;
        },
      );
    },
    optionsViewBuilder: (BuildContext context,
        AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
      return Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4.0,
          child: SizedBox(
            height: 200.0,
            width: MediaQuery.of(context).size.width * 2.1 / 3,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    // temporary change
                    // library saat ini belum bisa memilih value dari drop down apabila current valuenya sama dengan
                    // value yang sedang tampil
                    onSelected('');
                    onSelected(option);
                    PageData = option;
                  },
                  child: ListTile(
                    title: Text(option),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Widget _dropdownSuggestionSearchSurah(BuildContext context) {
  List<String> _surahString = surahNumberToSurahNameMap.entries.map((e) {
    return e.value;
  }).toList();

  return RawAutocomplete<String>(
    optionsBuilder: (TextEditingValue textEditingValue) {
      return _surahString.where((String option) {
        return option.contains(textEditingValue.text.toLowerCase());
      });
    },
    fieldViewBuilder: (BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted) {
      return TextFormField(
        controller: textEditingController,
        focusNode: focusNode,
        onFieldSubmitted: (String value) {
          onFieldSubmitted();
        },
        onChanged: (String page) {
          PageData = page;
        },
      );
    },
    optionsViewBuilder: (BuildContext context,
        AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
      return Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4.0,
          child: SizedBox(
            height: 200.0,
            width: MediaQuery.of(context).size.width * 3 / 7,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    onSelected(option);
                    PageData = option;
                  },
                  child: ListTile(
                    title: Text(option),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Widget _dropdownSuggestionSearchAyah(BuildContext context) {
  List<String> _ayahString = [];

  return RawAutocomplete<String>(
    optionsBuilder: (TextEditingValue textEditingValue) {
      return _ayahString.where((String option) {
        return option.contains(textEditingValue.text.toLowerCase());
      });
    },
    fieldViewBuilder: (BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted) {
      return TextFormField(
        controller: textEditingController,
        focusNode: focusNode,
        onFieldSubmitted: (String value) {
          onFieldSubmitted();
        },
        onChanged: (String page) {
          PageData = page;
        },
      );
    },
    optionsViewBuilder: (BuildContext context,
        AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
      return Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4.0,
          child: SizedBox(
            height: 200.0,
            width: MediaQuery.of(context).size.width * 3 / 7,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    onSelected(option);
                    PageData = option;
                  },
                  child: ListTile(
                    title: Text(option),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Widget tabviewSearchPage(BuildContext context) {
  return Column(
    children: [
      const SizedBox(
        height: 15.0,
      ),
      Container(
        margin: EdgeInsets.only(top: 10.0),
        width: MediaQuery.of(context).size.width,
        child: const Text('Page',
            textAlign: TextAlign.start, style: TextStyle(fontSize: 15.0)),
      ),
      _dropdownSuggestionSearchPage(context),
      const SizedBox(
        height: 30.0,
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
          int page = int.parse(PageData);
          int startPageInIndexValue = page - 1;
          print(page);

          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: SuratPageV3(
                startPageInIndex: startPageInIndexValue,
              ),
            ),
          );
        },
        child: Text('Search'),
      ),
    ],
  );
}

List<int> Numberpage() {
  List<int> Number = [];
  for (int count = 1; count < 605; count++) {
    Number.add(count);
  }
  return Number;
}

Widget tabviewSearchSurahandAyah(BuildContext context) {
  return Column(
    children: [
      const SizedBox(
        height: 5.0,
      ),
      Container(
        height: MediaQuery.of(context).size.height / 10,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Container(
                width: MediaQuery.of(context).size.width * 3 / 7,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: MediaQuery.of(context).size.width * 3 / 7,
                      child: const Text('Surah',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 15.0)),
                    ),
                    _dropdownSuggestionSearchSurah(context),
                  ],
                )),
            const SizedBox(
              width: 10.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 1.5 / 7,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    width: MediaQuery.of(context).size.width * 1.5 / 7,
                    child: const Text('Ayah',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 15.0)),
                  ),
                  _dropdownSuggestionSearchAyah(context),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 25.0,
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
        onPressed: () {},
        child: Text('Search'),
      ),
    ],
  );
}
