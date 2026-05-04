import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_habit_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/basmalah_widget.dart';
import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'ayah_item_widget.dart';

/// Widget that renders all pages in the full page (mushaf) mode using a PageView.
class FullPagePagesView extends ConsumerWidget {
  const FullPagePagesView({
    super.key,
    required this.orientation,
    required this.scrollController,
    required this.onTapToggleCTA,
    required this.onPageChanged,
  });

  final Orientation orientation;
  final AutoScrollController scrollController;
  final VoidCallback onTapToggleCTA;
  final void Function(int pageIndex) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(suratPageNavigationProvider);
    final contentState = ref.watch(suratPageContentProvider);
    final navNotifier = ref.read(suratPageNavigationProvider.notifier);

    List<Widget> allPages = <Widget>[];

    for (int idx = 0; idx < contentState.pages!.length; idx++) {
      allPages.add(_buildPageInFullPage(
        pageIndex: idx,
        context: context,
        contentState: contentState,
        navNotifier: navNotifier,
      ));
    }

    navNotifier.resetSeparatorBuilderIndex();

    return GestureDetector(
      onTap: onTapToggleCTA,
      child: PageView(
        reverse: true,
        controller: navState.pageController,
        onPageChanged: onPageChanged,
        children: allPages,
      ),
    );
  }

  Widget _buildPageInFullPage({
    required int pageIndex,
    required BuildContext context,
    required SuratPageContentState contentState,
    required SuratPageNavigationNotifier navNotifier,
  }) {
    final List<String> texts = List<String>.filled(15, '');
    final int page = pageIndex + 1;

    for (final Verse verse in contentState.pages![pageIndex].verses) {
      for (final Word word in verse.words) {
        texts[word.lineNumber - 1] += word.code;
      }
    }

    while (navNotifier.separatorBuilderIndex <
            contentState.fullPageSeparators!.length &&
        contentState.fullPageSeparators![navNotifier.separatorBuilderIndex]
                .page ==
            page) {
      final FullPageSeparator separator =
          contentState.fullPageSeparators![navNotifier.separatorBuilderIndex];
      if (!separator.bismillah) {
        texts[separator.line - 1] = separator.unicode!;
      }
      navNotifier.separatorBuilderIndex++;
    }

    List<Widget> textInWidgets = texts
        .map(
          (String words) => _buildFullPagePerLine(
            page: page,
            text: words,
            context: context,
          ),
        )
        .toList();

    final double bottomPadding = MediaQuery.of(context).size.height * 0.1;
    final double topPadding = MediaQuery.of(context).size.height * 0.05;

    if (orientation == Orientation.landscape) {
      return SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: textInWidgets,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(11, topPadding, 11, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: textInWidgets,
      ),
    );
  }

  Widget _buildFullPagePerLine({
    required String text,
    required int page,
    required BuildContext context,
  }) {
    String fontFamily = 'Page$page';
    if (text.length == 1) {
      fontFamily = 'SurahName';
    }

    if (text.isEmpty) {
      if (page == 1 || page == 2) {
        return const SizedBox.shrink();
      }
      return BasmalahWidget(orientation: orientation, isInFullPage: true);
    }

    if (page == 1 || page == 2) {
      if (orientation == Orientation.landscape) {
        return AutoSizeText(
          text,
          style: TextStyle(
            height: 1.5,
            fontFamily: fontFamily,
            color: Theme.of(context).colorScheme.primary,
          ),
          maxLines: 1,
          maxFontSize: double.infinity,
          minFontSize: 56,
        );
      }
      return AutoSizeText(
        text,
        style: TextStyle(
          height: 1.5,
          fontFamily: fontFamily,
          fontSize: 30,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (orientation == Orientation.landscape) {
      return SingleChildScrollView(
        child: Center(
          child: AutoSizeText(
            text,
            style: TextStyle(
              height: 1.5,
              fontFamily: fontFamily,
              color: Theme.of(context).colorScheme.primary,
            ),
            maxLines: 1,
            maxFontSize: double.infinity,
            minFontSize: 50,
          ),
        ),
      );
    }

    return Expanded(
      child: AutoSizeText(
        text,
        style: TextStyle(
          height: 1.5,
          fontFamily: fontFamily,
          fontSize: 30,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Widget that renders all pages in per-ayah (non-full page) mode using a PageView.
class PerAyahPagesView extends ConsumerWidget {
  const PerAyahPagesView({
    super.key,
    required this.orientation,
    required this.scrollController,
    required this.startPageInIndex,
    required this.onPageChanged,
  });

  final Orientation orientation;
  final AutoScrollController scrollController;
  final int startPageInIndex;
  final void Function(int pageIndex) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(suratPageNavigationProvider);
    final contentState = ref.watch(suratPageContentProvider);
    final habitState = ref.watch(suratPageHabitProvider);

    List<Widget> allPages = <Widget>[];

    for (int idx = 0; idx < contentState.pages!.length; idx++) {
      allPages.add(_buildPage(
        quranPageObject: contentState.pages![idx],
        pageNumberInQuran: idx + 1,
        contentState: contentState,
        habitState: habitState,
      ));
    }

    return PageView(
      reverse: true,
      controller: navState.pageController,
      onPageChanged: onPageChanged,
      children: allPages,
    );
  }

  Widget _buildPage({
    required QuranPage quranPageObject,
    required int pageNumberInQuran,
    required SuratPageContentState contentState,
    required SuratPageHabitState habitState,
  }) {
    List<Widget> ayahs = <Widget>[];
    for (int i = 0; i < quranPageObject.verses.length; i++) {
      bool useDivider = i != quranPageObject.verses.length - 1;
      Verse verse = quranPageObject.verses[i];

      ayahs.add(AyahItemWidget(
        verse: verse,
        useDivider: useDivider,
        fontSize: pageNumberInQuran == 1 || pageNumberInQuran == 2
            ? orientation == Orientation.landscape
                ? contentState
                    .readingSettings!.valueFontSizeArabicFirstSheetLandscape
                : contentState.readingSettings!.valueFontSizeArabicFirstSheet
            : orientation == Orientation.landscape
                ? contentState.readingSettings!.valueFontSizeArabicLandscape
                : contentState.readingSettings!.valueFontSizeArabic,
        pageNumberInQuran: pageNumberInQuran,
        orientation: orientation,
        scrollController: scrollController,
        startPageInIndex: startPageInIndex,
      ));
    }

    return ListView(
      padding: habitState.isRecording
          ? const EdgeInsets.only(top: 20)
          : EdgeInsets.zero,
      controller: scrollController,
      key: PageStorageKey('page$pageNumberInQuran'),
      children: ayahs,
    );
  }
}
