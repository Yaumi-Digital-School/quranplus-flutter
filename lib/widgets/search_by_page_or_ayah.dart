import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class SearchByPageOrAyah extends StatefulWidget {
  const SearchByPageOrAyah({
    Key? key,
    required this.verseMapper,
  }) : super(key: key);

  final Map<String, List<String>> verseMapper;

  @override
  State<SearchByPageOrAyah> createState() => _SearchByPageOrAyahState();
}

class _SearchByPageOrAyahState extends State<SearchByPageOrAyah> {
  final GlobalKey textFieldSurah = GlobalKey();
  final GlobalKey textFieldAyah = GlobalKey();
  final GlobalKey textFieldPage = GlobalKey();

  late Map<String, List<String>> verseMapper;
  late List<String> listOfSurahOptions;
  late List<String> listOfPages;
  late List<String> listOfAyahBasedOnSurah;
  late bool isSearchByAyahDisabled;
  int selectedPageOnSelectPage = 0;
  int selectedPageOnSelectAyah = 0;
  int selectedAyahID = 0;
  int selectedAyah = 0;
  int maxPageQuran = 604;
  int minPageQuran = 1;
  bool isSurahNotFound = false;

  @override
  void initState() {
    isSearchByAyahDisabled = true;
    verseMapper = widget.verseMapper;
    listOfPages = [for (int i = 1; i <= 604; i++) i.toString()];
    listOfAyahBasedOnSurah = <String>[];
    listOfSurahOptions = verseMapper.keys
        .map((e) =>
            "$e. ${surahNumberToSurahNameMap[int.tryParse(e)].toString()}")
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
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
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(5.0),
                  height: 34,
                  child: TabBar(
                    unselectedLabelColor: primary500,
                    indicator: BoxDecoration(
                      color: primary500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    tabs: const <Widget>[
                      Tab(
                        text: 'Page',
                      ),
                      Tab(
                        text: 'Ayah',
                      ),
                    ],
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
                children: <Widget>[
                  _tabviewSearchPage(context),
                  _tabviewSearchSurahandAyah(
                    context: context,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _dropdownSuggestionSearchPage(BuildContext context) {
    return RawAutocomplete<String>(
      initialValue: TextEditingValue(
        text: minPageQuran.toString(),
      ),
      optionsBuilder: (TextEditingValue textEditingValue) {
        return listOfPages.where(
          (String option) {
            return option.contains(
              textEditingValue.text.toLowerCase(),
            );
          },
        );
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          key: textFieldPage,
          keyboardType: TextInputType.number,
          style: bodyRegular2,
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          inputFormatters: <TextInputFormatter>[
            TextInputFormatter.withFunction(
              (_, newValue) {
                final int newValueInInt = int.parse(newValue.text);
                if (newValueInInt > maxPageQuran) {
                  selectedPageOnSelectPage = maxPageQuran;
                  return TextEditingValue(
                    text: maxPageQuran.toString(),
                  );
                }

                if (newValueInInt < minPageQuran) {
                  selectedPageOnSelectPage = minPageQuran;
                  return TextEditingValue(
                    text: minPageQuran.toString(),
                  );
                }

                return newValue;
              },
            ),
          ],
          onChanged: (String value) {
            selectedPageOnSelectPage = int.parse(value);
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        final RenderBox textFieldBox =
            textFieldPage.currentContext!.findRenderObject() as RenderBox;
        final double textFieldWidth = textFieldBox.size.width;

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 180,
              width: textFieldWidth,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
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
                      selectedPageOnSelectPage = int.parse(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Text(
                        option,
                        style: bodyRegular2,
                      ),
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

  Widget _tabviewSearchPage(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15.0,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Text(
            'Page',
            textAlign: TextAlign.start,
            style: bodyRegular2,
          ),
        ),
        _dropdownSuggestionSearchPage(context),
        const SizedBox(
          height: 21.0,
        ),
        ButtonSecondary(
          label: 'Search',
          onTap: _onPressedSearchPage,
        ),
      ],
    );
  }

  _onPressedSearchPage() {
    {
      int startPageInIndexValue = selectedPageOnSelectPage - 1;

      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: SuratPageV3(
            startPageInIndex: startPageInIndexValue,
          ),
        ),
      );
    }
  }

  Widget _tabviewSearchSurahandAyah({
    required BuildContext context,
  }) {
    return Column(
      children: [
        const SizedBox(
          height: 15.0,
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Surah',
                      style: bodyRegular2,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _dropdownSuggestionSearchSurah(
                    context,
                    listOfSurahOptions,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    isSurahNotFound ? "Surah not found" : "",
                    style: bodyRegular1.copyWith(fontSize: 8, color: exit500),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Ayah',
                      textAlign: TextAlign.start,
                      style: bodyRegular2,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _dropdownSuggestionSearchAyah(
                    context: context,
                    ayahOptions: listOfAyahBasedOnSurah,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    listOfAyahBasedOnSurah.isNotEmpty && !isSurahNotFound
                        ? "${listOfAyahBasedOnSurah.length} Ayah"
                        : "",
                    style:
                        bodyRegular1.copyWith(fontSize: 8, color: neutral500),
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 21.0,
        ),
        ButtonSecondary(
          label: 'Search',
          onTap: _onPressedSearchSurahandAyah(
            isSearchByAyahDisabled,
          ),
        )
      ],
    );
  }

  _onPressedSearchSurahandAyah(bool isSearchByAyahDisabled) {
    if (isSearchByAyahDisabled || isSurahNotFound) {
      return null;
    } else {
      return () {
        int startPageInIndexValue = selectedPageOnSelectAyah - 1;

        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: SuratPageV3(
              startPageInIndex: startPageInIndexValue,
              firstPagePointerIndex: selectedAyahID,
            ),
          ),
        );
      };
    }
  }

  Widget _dropdownSuggestionSearchSurah(
    BuildContext context,
    List<String> listOfSurahs,
  ) {
    return RawAutocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        final list = listOfSurahs.where((String option) {
          final String optionInLower = option.toLowerCase();
          return optionInLower.contains(textEditingValue.text.toLowerCase());
        });

        if (list.isEmpty &&
            textEditingValue.text.isNotEmpty &&
            !isSurahNotFound) {
          setState(() {
            isSurahNotFound = true;
          });
        }

        if (list.isNotEmpty && isSurahNotFound) {
          setState(() {
            isSurahNotFound = false;
          });
        }

        if (textEditingValue.text.isEmpty && isSurahNotFound) {
          setState(() {
            isSurahNotFound = false;
          });
        }

        return list;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          key: textFieldSurah,
          controller: textEditingController,
          style: bodyRegular2,
          focusNode: focusNode,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            isDense: true,
          ),
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          validator: (String? value) {},
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        final RenderBox textFieldBox =
            textFieldSurah.currentContext!.findRenderObject() as RenderBox;
        final double textFieldWidth = textFieldBox.size.width;

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 180,
              width: textFieldWidth,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String surahName = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      // temporary change
                      // library saat ini belum bisa memilih value dari drop down apabila current valuenya sama dengan
                      // value yang sedang tampil
                      onSelected('');
                      onSelected(surahName);
                      final numberOfSurah = surahName.split(".")[0];
                      final listAyah = verseMapper[numberOfSurah] ?? <String>[];
                      final ayahId =
                          listAyah.isNotEmpty ? listAyah[0].split(":")[2] : "0";
                      final page =
                          listAyah.isNotEmpty ? listAyah[0].split(":")[1] : "0";

                      setState(() {
                        listOfAyahBasedOnSurah = listAyah;
                        selectedAyahID = int.parse(ayahId);
                        selectedPageOnSelectAyah = int.parse(page);
                        isSearchByAyahDisabled = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Text(
                        surahName,
                        style: bodyRegular2,
                      ),
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

  Widget _dropdownSuggestionSearchAyah({
    required BuildContext context,
    required List<String> ayahOptions,
  }) {
    return RawAutocomplete<String>(
      key: GlobalKey(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        return ayahOptions.where((String option) {
          final String optionAsPage = option.split(':')[0];
          return optionAsPage.contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          key: textFieldAyah,
          keyboardType: TextInputType.number,
          style: bodyRegular2,
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            isDense: true,
          ),
          inputFormatters: <TextInputFormatter>[
            TextInputFormatter.withFunction(
              (_, newValue) {
                final int newValueInInt = int.parse(newValue.text);
                if (newValueInInt > ayahOptions.length) {
                  return TextEditingValue(
                    text: ayahOptions.length.toString(),
                  );
                }

                return newValue;
              },
            ),
          ],
          onChanged: (String ayah) {
            selectedAyah = int.parse(ayah);
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        final RenderBox textFieldBox =
            textFieldAyah.currentContext!.findRenderObject() as RenderBox;
        final double textFieldWidth = textFieldBox.size.width;

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 180,
              width: textFieldWidth,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final List<String> splittedOption =
                      options.elementAt(index).split(':');
                  final String ayahOption = splittedOption[0];
                  final String page = splittedOption[1];
                  final String ayahID = splittedOption[2];

                  return GestureDetector(
                    onTap: () {
                      // temporary change
                      // library saat ini belum bisa memilih value dari drop down apabila current valuenya sama dengan
                      // value yang sedang tampil

                      onSelected('');
                      onSelected(ayahOption);
                      selectedPageOnSelectAyah = int.parse(page);
                      selectedAyah = int.parse(ayahOption);

                      selectedAyahID = int.parse(ayahID);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Text(
                        ayahOption,
                        style: bodyRegular2,
                      ),
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
}
