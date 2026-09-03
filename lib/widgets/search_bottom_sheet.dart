import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/surat_page_v3.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';

/// Homepage search UI, rendered as a bottom sheet.
///
/// Replaces the old floating-autocomplete dialog with two-column scrollable
/// pickers. [onSearch] is a test seam: when provided the parsing/selection
/// result is handed back through it instead of navigating; in production it is
/// null and the sheet does the real `Navigator.pushReplacement` fade.
class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet({
    super.key,
    required this.verseMapper,
    this.onSearch,
  });

  /// Key = surah number as string ("1".."114"); value = list of
  /// `"ayahNumber:page:ayahID"` entries (first entry is ayah 1).
  final Map<String, List<String>> verseMapper;

  /// Test seam. When null the sheet navigates for real.
  final void Function(SuratPageV3Param param)? onSearch;

  static void show(
    BuildContext context,
    Map<String, List<String>> verseMapper,
  ) {
    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: SearchBottomSheet(verseMapper: verseMapper),
    );
  }

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  static const int _maxPage = 604;
  static const int _minPage = 1;

  final TextEditingController _surahSearchController = TextEditingController();
  final TextEditingController _ayahSearchController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  final ScrollController _ayahScrollController = ScrollController();

  late final List<String> _allSurahOptions;
  late final List<String> _allPages;

  String _surahQuery = '';
  String _ayahQuery = '';
  String _pageQuery = '';

  // Ayah tab selection.
  String? _selectedSurahLabel;
  List<String> _ayahOptions = <String>[];
  int? _selectedAyahIndex;
  int _selectedPageOfAyah = 0;
  int _selectedAyahID = 0;

  // Page tab selection.
  int _selectedPage = _minPage;

  @override
  void initState() {
    super.initState();
    _allSurahOptions = widget.verseMapper.keys
        .map((e) => "$e. ${surahNumberToSurahNameMap[int.tryParse(e)]}")
        .toList();
    _allPages = <String>[for (int i = _minPage; i <= _maxPage; i++) '$i'];
    _pageController.text = _minPage.toString();
  }

  @override
  void dispose() {
    _surahSearchController.dispose();
    _ayahSearchController.dispose();
    _pageController.dispose();
    _ayahScrollController.dispose();
    super.dispose();
  }

  List<String> get _filteredSurahOptions {
    final String query = _surahQuery.toLowerCase();
    if (query.isEmpty) return _allSurahOptions;
    return _allSurahOptions
        .where((String option) => option.toLowerCase().contains(query))
        .toList();
  }

  bool get _isSurahNotFound =>
      _surahQuery.isNotEmpty && _filteredSurahOptions.isEmpty;

  List<String> get _filteredPages {
    if (_pageQuery.isEmpty) return _allPages;
    return _allPages
        .where((String option) => option.contains(_pageQuery))
        .toList();
  }

  /// Ayah entries of the selected surah, filtered by `contains` on the ayah
  /// number (same matching the old dialog used).
  List<String> get _filteredAyahOptions {
    if (_ayahQuery.isEmpty) return _ayahOptions;
    return _ayahOptions
        .where((String option) => option.split(':')[0].contains(_ayahQuery))
        .toList();
  }

  Color _primaryText(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  Color _mutedText(BuildContext context) => QPColors.getColorBasedTheme(
    dark: QPColors.whiteRoot,
    light: QPColors.neutral600,
    brown: QPColors.brownModeHeavy,
    context: context,
  );

  Color _highlightColor(BuildContext context) => QPColors.getColorBasedTheme(
    dark: QPColors.darkModeFair,
    light: QPColors.whiteSoft,
    brown: QPColors.brownModeFair,
    context: context,
  );

  // Same trio ayah_item_widget's tafsir container uses, so the fields read as
  // filled cards against the theme-aware sheet background (esp. dark mode).
  Color _fieldFillColor(BuildContext context) => QPColors.getColorBasedTheme(
    dark: QPColors.darkModeFair,
    light: QPColors.whiteSoft,
    brown: QPColors.brownModeHeavy,
    context: context,
  );

  void _selectSurah(String label) {
    final String number = label.split('.')[0];
    final List<String> ayahList = widget.verseMapper[number] ?? <String>[];
    final int firstAyahID = ayahList.isNotEmpty
        ? int.tryParse(ayahList[0].split(':')[2]) ?? 0
        : 0;
    final int firstPage = ayahList.isNotEmpty
        ? int.tryParse(ayahList[0].split(':')[1]) ?? 0
        : 0;

    setState(() {
      _selectedSurahLabel = label;
      _ayahOptions = ayahList;
      _selectedAyahIndex = ayahList.isNotEmpty ? 0 : null;
      _selectedAyahID = firstAyahID;
      _selectedPageOfAyah = firstPage;
      // Selecting a surah resets the ayah picker back to ayah 1.
      _ayahQuery = '';
    });

    _ayahSearchController.clear();
    if (_ayahScrollController.hasClients) {
      _ayahScrollController.jumpTo(0);
    }
  }

  /// Mutates the ayah selection fields for [fullIndex] into [_ayahOptions].
  /// Caller is responsible for wrapping in setState.
  void _applyAyahSelection(int fullIndex) {
    final List<String> parts = _ayahOptions[fullIndex].split(':');
    _selectedAyahIndex = fullIndex;
    _selectedPageOfAyah = int.tryParse(parts[1]) ?? 0;
    _selectedAyahID = int.tryParse(parts[2]) ?? 0;
  }

  void _selectAyah(int fullIndex) {
    setState(() => _applyAyahSelection(fullIndex));
  }

  void _onSearchAyah() {
    if (_selectedSurahLabel == null) return;
    _submit(
      SuratPageV3Param(
        startPageInIndex: _selectedPageOfAyah - 1,
        firstPagePointerIndex: _selectedAyahID,
      ),
    );
  }

  void _onSearchPage() {
    _submit(SuratPageV3Param(startPageInIndex: _selectedPage - 1));
  }

  void _submit(SuratPageV3Param param) {
    final void Function(SuratPageV3Param param)? onSearch = widget.onSearch;
    if (onSearch != null) {
      onSearch(param);
      return;
    }

    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: SuratPageV3(param: param),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double maxContentHeight = mq.size.height * 0.6;
    // Shrink the fixed content area by the keyboard height so the sheet does
    // not overflow when the keyboard opens (BaseWidgetBottomSheet pads the
    // bottom by viewInsets.bottom).
    final double contentHeight = (maxContentHeight - mq.viewInsets.bottom)
        .clamp(340.0, maxContentHeight);

    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      // Hard guarantee against overflow on short screens where even the clamped
      // minimum does not fit. The ConstrainedBox caps the scroll view to the
      // screen so it never receives unbounded height from the outer Column.
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mq.size.height),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTabBar(),
              SizedBox(
                height: contentHeight,
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _buildPageTab(context),
                    _buildAyahTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: neutral100,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: neutral300, blurRadius: 9.0, spreadRadius: 0.9),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(5.0),
        height: 34,
        child: const TabBar(
          labelColor: neutral100,
          unselectedLabelColor: primary500,
          // Fill the whole tab half with the pill (M3 defaults to `label`,
          // which collapses the pill to the text bounds) and drop the M3
          // underline divider.
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: primary500,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          tabs: <Widget>[
            Tab(text: 'Page'),
            Tab(text: 'Ayah'),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahTab(BuildContext context) {
    // Built as shared rows (headers / fields / status / lists) instead of two
    // independent columns, so the surah and ayah forms line up exactly by
    // construction regardless of the search icon or the "not found" status.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 12),
        // Row 1 — headers (fixed height so the fields start at the same y).
        SizedBox(height: 22, child: _buildAyahHeaderRow(context)),
        const SizedBox(height: 6),
        // Row 2 — fields with identical height metrics.
        Row(
          children: <Widget>[
            Expanded(flex: 3, child: _buildSurahField(context)),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: _buildAyahField(context)),
          ],
        ),
        const SizedBox(height: 6),
        // Row 3 — status line, ALWAYS present so it never shifts the lists.
        SizedBox(
          height: 18,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _isSurahNotFound ? 'Surah not found' : '',
              style: bodyRegular1.copyWith(fontSize: 12, color: exit500),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Row 4 — the two option lists, sharing the same top by construction.
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(flex: 3, child: _buildSurahListView(context)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildAyahListView(context)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ButtonSecondary(
          key: const Key('search_button_ayah'),
          label: 'Search',
          onTap: _selectedSurahLabel == null ? null : _onSearchAyah,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAyahHeaderRow(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Text(
            'Surah',
            style: bodySemibold2.copyWith(color: _primaryText(context)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                'Ayah',
                style: bodySemibold2.copyWith(color: _primaryText(context)),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _ayahOptions.isNotEmpty && !_isSurahNotFound
                      ? '${_ayahOptions.length} Ayah'
                      : '',
                  overflow: TextOverflow.ellipsis,
                  style: bodyRegular1.copyWith(
                    fontSize: 12,
                    color: _mutedText(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSurahField(BuildContext context) {
    return TextField(
      key: const Key('search_surah_field'),
      controller: _surahSearchController,
      style: bodyRegular2.copyWith(color: _primaryText(context)),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        filled: true,
        fillColor: _fieldFillColor(context),
        // Small icon + zero-min constraints so it does not inflate the field
        // height beyond the (icon-less) ayah field.
        prefixIcon: Icon(Icons.search, size: 16, color: _mutedText(context)),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
        hintText: 'Search surah',
        hintStyle: bodyRegular2.copyWith(color: _mutedText(context)),
        border: const OutlineInputBorder(),
      ),
      onChanged: (String value) {
        setState(() {
          _surahQuery = value;
        });
      },
    );
  }

  Widget _buildAyahField(BuildContext context) {
    final bool ayahEnabled = _selectedSurahLabel != null;
    return TextField(
      key: const Key('search_ayah_field'),
      controller: _ayahSearchController,
      enabled: ayahEnabled,
      keyboardType: TextInputType.number,
      style: bodyRegular2.copyWith(
        color: ayahEnabled ? _primaryText(context) : _mutedText(context),
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        filled: true,
        fillColor: _fieldFillColor(context),
        hintText: 'Ayah',
        hintStyle: bodyRegular2.copyWith(color: _mutedText(context)),
        border: const OutlineInputBorder(),
      ),
      inputFormatters: <TextInputFormatter>[
        TextInputFormatter.withFunction((
          TextEditingValue oldValue,
          TextEditingValue newValue,
        ) {
          if (newValue.text.isEmpty) return newValue;
          final int? parsed = int.tryParse(newValue.text);
          if (parsed == null) return oldValue; // reject non-numeric
          final int maxAyah = _ayahOptions.length;
          if (maxAyah > 0 && parsed > maxAyah) {
            return TextEditingValue(
              text: maxAyah.toString(),
              selection: TextSelection.collapsed(
                offset: maxAyah.toString().length,
              ),
            );
          }
          return newValue;
        }),
      ],
      onChanged: (String value) {
        setState(() {
          _ayahQuery = value;
          if (value.isNotEmpty) {
            final int matchIndex = _ayahOptions.indexWhere(
              (String option) => option.split(':')[0] == value,
            );
            if (matchIndex != -1) {
              _applyAyahSelection(matchIndex);
            }
          }
        });
      },
    );
  }

  Widget _buildSurahListView(BuildContext context) {
    final List<String> options = _filteredSurahOptions;
    return ListView.builder(
      key: const Key('search_surah_list'),
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) {
        final String label = options[index];
        return _buildOptionRow(
          context: context,
          text: label,
          isSelected: label == _selectedSurahLabel,
          onTap: () => _selectSurah(label),
        );
      },
    );
  }

  Widget _buildAyahListView(BuildContext context) {
    if (_ayahOptions.isEmpty) {
      return Text(
        'Select a surah',
        style: bodyRegular2.copyWith(color: _mutedText(context)),
      );
    }

    final List<String> options = _filteredAyahOptions;
    return ListView.builder(
      key: const Key('search_ayah_list'),
      controller: _ayahScrollController,
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) {
        final String option = options[index];
        final int fullIndex = _ayahOptions.indexOf(option);
        final String ayahNumber = option.split(':')[0];
        return _buildOptionRow(
          context: context,
          text: ayahNumber,
          isSelected: fullIndex == _selectedAyahIndex,
          onTap: () => _selectAyah(fullIndex),
        );
      },
    );
  }

  Widget _buildPageTab(BuildContext context) {
    final List<String> options = _filteredPages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        Text(
          'Page',
          style: bodySemibold2.copyWith(color: _primaryText(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('search_page_field'),
          controller: _pageController,
          keyboardType: TextInputType.number,
          style: bodyRegular2.copyWith(color: _primaryText(context)),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: _fieldFillColor(context),
            hintText: 'Page number',
            hintStyle: bodyRegular2.copyWith(color: _mutedText(context)),
            border: const OutlineInputBorder(),
          ),
          inputFormatters: <TextInputFormatter>[
            TextInputFormatter.withFunction((
              TextEditingValue oldValue,
              TextEditingValue newValue,
            ) {
              // Allow empty text while typing (the old formatter crashed here
              // by calling int.parse('')).
              if (newValue.text.isEmpty) return newValue;
              final int? parsed = int.tryParse(newValue.text);
              if (parsed == null) return oldValue;
              if (parsed > _maxPage) {
                return TextEditingValue(
                  text: _maxPage.toString(),
                  selection: TextSelection.collapsed(
                    offset: _maxPage.toString().length,
                  ),
                );
              }
              if (parsed < _minPage) {
                return TextEditingValue(
                  text: _minPage.toString(),
                  selection: TextSelection.collapsed(
                    offset: _minPage.toString().length,
                  ),
                );
              }
              return newValue;
            }),
          ],
          onChanged: (String value) {
            setState(() {
              _pageQuery = value;
              final int? parsed = int.tryParse(value);
              if (parsed != null) _selectedPage = parsed;
            });
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            key: const Key('search_page_list'),
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final String option = options[index];
              return _buildOptionRow(
                context: context,
                text: option,
                isSelected: option == _selectedPage.toString(),
                onTap: () {
                  setState(() {
                    _pageController.text = option;
                    _pageQuery = option;
                    _selectedPage = int.tryParse(option) ?? _selectedPage;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ButtonSecondary(
          key: const Key('search_button_page'),
          label: 'Search',
          onTap: _onSearchPage,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildOptionRow({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _highlightColor(context) : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(
          text,
          style: bodyRegular2.copyWith(color: _primaryText(context)),
        ),
      ),
    );
  }
}
