import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
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
    required this.onTapToggleCTA,
    required this.onPageChanged,
  });

  final Orientation orientation;
  final VoidCallback onTapToggleCTA;
  final void Function(int pageIndex) onPageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = ref.watch(
      suratPageNavigationProvider.select((s) => s.pageController),
    );
    final contentState = ref.watch(suratPageContentProvider);

    final Map<int, List<FullPageSeparator>> separatorsByPage = {};
    for (final FullPageSeparator sep in contentState.fullPageSeparators ?? []) {
      separatorsByPage.putIfAbsent(sep.page, () => []).add(sep);
    }

    return GestureDetector(
      onTap: onTapToggleCTA,
      child: NotificationListener<ScrollStartNotification>(
        onNotification: (notification) {
          if (notification.depth == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(suratPageHabitProvider.notifier)
                  .setOnReadCTAVisible(false);
            });
          }
          return false;
        },
        child: PageView.builder(
          allowImplicitScrolling: true,
          reverse: true,
          controller: pageController,
          onPageChanged: onPageChanged,
          itemCount: contentState.pages!.length,
          itemBuilder: (context, idx) => _buildPageInFullPage(
            pageIndex: idx,
            context: context,
            contentState: contentState,
            separatorsByPage: separatorsByPage,
          ),
        ),
      ),
    );
  }

  Widget _buildPageInFullPage({
    required int pageIndex,
    required BuildContext context,
    required SuratPageContentState contentState,
    required Map<int, List<FullPageSeparator>> separatorsByPage,
  }) {
    final List<String> texts = List<String>.filled(15, '');
    final int page = pageIndex + 1;

    for (final Verse verse in contentState.pages![pageIndex].verses) {
      for (final Word word in verse.words) {
        texts[word.lineNumber - 1] += word.code;
      }
    }

    for (final FullPageSeparator separator in separatorsByPage[page] ?? []) {
      if (!separator.bismillah) {
        texts[separator.line - 1] = separator.unicode!;
      }
    }

    final List<Widget> textInWidgets = texts
        .map(
          (String words) =>
              _buildFullPagePerLine(page: page, text: words, context: context),
        )
        .toList();

    final double bottomPadding = MediaQuery.of(context).size.height * 0.1;
    final double topPadding = MediaQuery.of(context).size.height * 0.05;

    if (orientation == Orientation.landscape) {
      // Each pre-built landscape page uses its own internal scroll controller
      // to avoid attaching the shared AutoScrollController to multiple views.
      return SingleChildScrollView(
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

    // Portrait, regular pages (the common reading path). Uses a cached,
    // pre-fitted plain Text instead of AutoSizeText: the fitted font size is
    // computed once per (font, width, line) and reused, removing AutoSizeText's
    // repeated multi-pass Arabic text shaping on every build/layout — the main
    // source of the fullpage swipe lag.
    return Expanded(
      child: _FittedMushafLine(
        text: text,
        fontFamily: fontFamily,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Renders one mushaf line as plain [Text], sized so a too-wide line shrinks to
/// fill the available width (matching the previous AutoSizeText behaviour).
///
/// The fitted size is derived from a single [TextPainter] measurement and
/// cached, so rebuilds — including the next page built mid-swipe by
/// `allowImplicitScrolling` — reuse it instead of re-shaping the text.
class _FittedMushafLine extends StatelessWidget {
  const _FittedMushafLine({
    required this.text,
    required this.fontFamily,
    required this.color,
  });

  final String text;
  final String fontFamily;
  final Color color;

  static const double _baseFontSize = 30;

  /// Fitted font sizes keyed by font family + rounded available width + line.
  static final Map<String, double> _sizeCache = <String, double>{};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final String cacheKey = '$fontFamily|${maxWidth.round()}|$text';
        final double fontSize = _sizeCache.putIfAbsent(
          cacheKey,
          () => _computeFittedSize(maxWidth),
        );

        return Text(
          text,
          maxLines: 1,
          style: TextStyle(
            height: 1.5,
            fontFamily: fontFamily,
            fontSize: fontSize,
            color: color,
          ),
        );
      },
    );
  }

  double _computeFittedSize(double maxWidth) {
    if (maxWidth <= 0 || text.isEmpty) return _baseFontSize;

    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          height: 1.5,
        ).copyWith(fontFamily: fontFamily, fontSize: _baseFontSize),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 1,
    )..layout();

    final double intrinsicWidth = painter.width;
    painter.dispose();

    // Lines that already fit keep the design size; wider lines shrink to fill
    // the width. Glyph width scales ~linearly with font size.
    if (intrinsicWidth <= 0 || intrinsicWidth <= maxWidth) {
      return _baseFontSize;
    }
    return _baseFontSize * maxWidth / intrinsicWidth;
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
    final pageController = ref.watch(
      suratPageNavigationProvider.select((s) => s.pageController),
    );
    final contentState = ref.watch(suratPageContentProvider);
    final habitState = ref.watch(suratPageHabitProvider);

    // allowImplicitScrolling is intentionally NOT set here: the shared
    // AutoScrollController cannot be attached to multiple ListViews
    // simultaneously (one per pre-built adjacent page), which would crash.
    return PageView.builder(
      reverse: true,
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: contentState.pages!.length,
      itemBuilder: (context, idx) => _buildPage(
        quranPageObject: contentState.pages![idx],
        pageNumberInQuran: idx + 1,
        contentState: contentState,
        habitState: habitState,
      ),
    );
  }

  Widget _buildPage({
    required QuranPage quranPageObject,
    required int pageNumberInQuran,
    required SuratPageContentState contentState,
    required SuratPageHabitState habitState,
  }) {
    final List<Widget> ayahs = <Widget>[];
    for (int i = 0; i < quranPageObject.verses.length; i++) {
      final bool useDivider = i != quranPageObject.verses.length - 1;
      final Verse verse = quranPageObject.verses[i];

      ayahs.add(
        AyahItemWidget(
          verse: verse,
          useDivider: useDivider,
          fontSize: pageNumberInQuran == 1 || pageNumberInQuran == 2
              ? orientation == Orientation.landscape
                    ? contentState
                          .readingSettings!
                          .valueFontSizeArabicFirstSheetLandscape
                    : contentState
                          .readingSettings!
                          .valueFontSizeArabicFirstSheet
              : orientation == Orientation.landscape
              ? contentState.readingSettings!.valueFontSizeArabicLandscape
              : contentState.readingSettings!.valueFontSizeArabic,
          pageNumberInQuran: pageNumberInQuran,
          orientation: orientation,
          scrollController: scrollController,
          startPageInIndex: startPageInIndex,
        ),
      );
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
