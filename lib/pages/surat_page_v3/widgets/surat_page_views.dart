import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/full_page_ayah_utils.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/ayah_detail_bottom_sheet.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/widgets/basmalah_widget.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/core/models/full_page_separator.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
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
    this.onAyahLongPressed,
  });

  final Orientation orientation;
  final AutoScrollController scrollController;
  final VoidCallback onTapToggleCTA;
  final void Function(int pageIndex) onPageChanged;

  /// Test seam: invoked when an ayah is long-pressed (1s). When null the real
  /// [AyahDetailBottomSheet] is opened instead.
  final void Function(int ayahId)? onAyahLongPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentState = ref.watch(suratPageContentProvider);
    // select (not read): the controller is replaced when toggling full page mode
    // via recreatePageController(), and we must rebuild with the new controller.
    final pageController = ref.watch(
      suratPageNavigationProvider.select((s) => s.pageController),
    );

    return GestureDetector(
      onTap: onTapToggleCTA,
      child: PageView.builder(
        reverse: true,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        allowImplicitScrolling: true,
        itemCount: contentState.pages!.length,
        itemBuilder: (context, index) => _buildPageInFullPage(
          pageIndex: index,
          context: context,
          contentState: contentState,
        ),
      ),
    );
  }

  Widget _buildPageInFullPage({
    required int pageIndex,
    required BuildContext context,
    required SuratPageContentState contentState,
  }) {
    final int page = pageIndex + 1;
    final QuranPage quranPage = contentState.pages![pageIndex];

    // Per-verse segments per line (interactive) + the concatenated per-line
    // text derived from them (parity with the old renderer).
    final List<List<AyahLineSegment>> segments = segmentFullPageLines(
      quranPage,
    );
    final List<String> texts = List<String>.generate(
      15,
      (int line) => segments[line].map((AyahLineSegment s) => s.text).join(),
      growable: false,
    );

    final Set<int> separatorLines = <int>{};
    final List<FullPageSeparator> separators =
        contentState.separatorsByPage[page] ?? const <FullPageSeparator>[];
    for (final FullPageSeparator separator in separators) {
      if (!separator.bismillah) {
        texts[separator.line - 1] = separator.unicode!;
        separatorLines.add(separator.line);
      }
    }

    final List<Widget> textInWidgets = <Widget>[];
    for (int line = 0; line < 15; line++) {
      final bool isSeparator = separatorLines.contains(line + 1);
      if (!isSeparator && segments[line].isNotEmpty) {
        textInWidgets.add(
          _buildInteractiveLine(
            segments: segments[line],
            page: page,
            line: line,
            context: context,
          ),
        );
      } else {
        textInWidgets.add(
          _buildFullPagePerLine(
            page: page,
            text: texts[line],
            context: context,
          ),
        );
      }
    }

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

  /// Interactive counterpart of the non-empty, non-separator glyph line. Mirrors
  /// the AutoSizeText params + wrapping of [_buildFullPagePerLine] exactly, but
  /// renders per-verse [TextSpan]s so each ayah can be tapped/held.
  Widget _buildInteractiveLine({
    required List<AyahLineSegment> segments,
    required int page,
    required int line,
    required BuildContext context,
  }) {
    final Color color = Theme.of(context).colorScheme.primary;
    final Key key = ValueKey<String>('fullpage_line_${page}_$line');

    if (page == 1 || page == 2) {
      if (orientation == Orientation.landscape) {
        return _FullPageLine(
          key: key,
          segments: segments,
          style: TextStyle(height: 1.5, fontFamily: 'Page$page', color: color),
          minFontSize: 56,
          maxLines: 1,
          onAyahLongPressed: onAyahLongPressed,
        );
      }
      return _FullPageLine(
        key: key,
        segments: segments,
        style: TextStyle(
          height: 1.5,
          fontFamily: 'Page$page',
          fontSize: 30,
          color: color,
        ),
        onAyahLongPressed: onAyahLongPressed,
      );
    }

    if (orientation == Orientation.landscape) {
      return SingleChildScrollView(
        child: Center(
          child: _FullPageLine(
            key: key,
            segments: segments,
            style: TextStyle(
              height: 1.5,
              fontFamily: 'Page$page',
              color: color,
            ),
            minFontSize: 50,
            maxLines: 1,
            onAyahLongPressed: onAyahLongPressed,
          ),
        ),
      );
    }

    return Expanded(
      child: _FullPageLine(
        key: key,
        segments: segments,
        style: TextStyle(
          height: 1.5,
          fontFamily: 'Page$page',
          fontSize: 30,
          color: color,
        ),
        onAyahLongPressed: onAyahLongPressed,
      ),
    );
  }
}

/// A single interactive mushaf line: renders one [TextSpan] per verse segment
/// (auto-sized like the rest of the page). A tap highlights the ayah under the
/// finger; a 1-second hold highlights it AND opens the ayah detail sheet.
///
/// Owns the per-segment [TapGestureRecognizer]s (disposed in [dispose]); the
/// 1-second [LongPressGestureRecognizer] is owned by the [RawGestureDetector].
class _FullPageLine extends ConsumerStatefulWidget {
  const _FullPageLine({
    super.key,
    required this.segments,
    required this.style,
    required this.onAyahLongPressed,
    this.minFontSize = 12,
    this.maxLines,
  });

  final List<AyahLineSegment> segments;
  final TextStyle style;
  final double minFontSize;
  final int? maxLines;
  final void Function(int ayahId)? onAyahLongPressed;

  @override
  ConsumerState<_FullPageLine> createState() => _FullPageLineState();
}

class _FullPageLineState extends ConsumerState<_FullPageLine> {
  List<TapGestureRecognizer> _tapRecognizers = <TapGestureRecognizer>[];

  /// The ayah under the finger at pointer-down, used to resolve which ayah a
  /// 1-second hold refers to (the long-press recognizer only knows the raw
  /// offset, which the auto-sized paragraph does not expose).
  int? _pressedAyahId;

  @override
  void initState() {
    super.initState();
    _createTapRecognizers();
  }

  void _createTapRecognizers() {
    _tapRecognizers = List<TapGestureRecognizer>.generate(
      widget.segments.length,
      (int i) => TapGestureRecognizer()
        ..onTapDown = ((_) => _pressedAyahId = widget.segments[i].ayahId)
        ..onTap = (() => _onTapSegment(i)),
    );
  }

  void _disposeTapRecognizers() {
    for (final TapGestureRecognizer recognizer in _tapRecognizers) {
      recognizer.dispose();
    }
    _tapRecognizers = <TapGestureRecognizer>[];
  }

  @override
  void didUpdateWidget(covariant _FullPageLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments.length != widget.segments.length) {
      _disposeTapRecognizers();
      _createTapRecognizers();
    }
  }

  @override
  void dispose() {
    _disposeTapRecognizers();
    super.dispose();
  }

  void _onTapSegment(int index) {
    ref
        .read(suratPageNavigationProvider.notifier)
        .setHighlightedAyah(widget.segments[index].ayahId);
  }

  void _onHold() {
    final int? ayahId = _pressedAyahId;
    if (ayahId == null) return;

    ref.read(suratPageNavigationProvider.notifier).setHighlightedAyah(ayahId);

    final void Function(int ayahId)? seam = widget.onAyahLongPressed;
    if (seam != null) {
      seam(ayahId);
      return;
    }

    GeneralBottomSheet.showBaseBottomSheet(
      context: context,
      widgetChild: AyahDetailBottomSheet(initialAyahId: ayahId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int? highlightedAyahId = ref.watch(
      suratPageNavigationProvider.select((s) => s.highlightedAyahId),
    );
    // Dark mode uses a translucent brand tint (not an opaque grey chip) so the
    // near-white glyphs keep their brightness when highlighted.
    final Color highlightColor = QPColors.getColorBasedTheme(
      light: QPColors.brandSoft,
      dark: QPColors.brandFair.withValues(alpha: 0.3),
      brown: QPColors.brownModeFair,
      context: context,
    );

    final List<InlineSpan> spans = <InlineSpan>[];
    for (int i = 0; i < widget.segments.length; i++) {
      final AyahLineSegment segment = widget.segments[i];
      final bool isHighlighted =
          highlightedAyahId != null && segment.ayahId == highlightedAyahId;
      spans.add(
        TextSpan(
          text: segment.text,
          style: isHighlighted
              ? TextStyle(backgroundColor: highlightColor)
              : null,
          recognizer: _tapRecognizers[i],
        ),
      );
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: <Type, GestureRecognizerFactory>{
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(
                duration: const Duration(seconds: 1),
              ),
              (LongPressGestureRecognizer instance) {
                instance
                  ..onLongPressDown = ((_) => _pressedAyahId = null)
                  ..onLongPress = _onHold;
              },
            ),
      },
      child: AutoSizeText.rich(
        TextSpan(children: spans),
        style: widget.style,
        minFontSize: widget.minFontSize,
        maxFontSize: double.infinity,
        maxLines: widget.maxLines,
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
    final contentState = ref.watch(suratPageContentProvider);
    // select (not read): the controller is replaced when toggling full page mode
    // via recreatePageController(), and we must rebuild with the new controller.
    final pageController = ref.watch(
      suratPageNavigationProvider.select((s) => s.pageController),
    );
    final bool isRecording = ref.watch(
      suratPageHabitProvider.select((s) => s.isRecording),
    );

    return PageView.builder(
      reverse: true,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: contentState.pages!.length,
      itemBuilder: (context, index) => _buildPage(
        quranPageObject: contentState.pages![index],
        pageNumberInQuran: index + 1,
        contentState: contentState,
        isRecording: isRecording,
      ),
    );
  }

  Widget _buildPage({
    required QuranPage quranPageObject,
    required int pageNumberInQuran,
    required SuratPageContentState contentState,
    required bool isRecording,
  }) {
    List<Widget> ayahs = <Widget>[];
    for (int i = 0; i < quranPageObject.verses.length; i++) {
      bool useDivider = i != quranPageObject.verses.length - 1;
      Verse verse = quranPageObject.verses[i];

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
      padding: isRecording ? const EdgeInsets.only(top: 20) : EdgeInsets.zero,
      controller: scrollController,
      key: PageStorageKey('page$pageNumberInQuran'),
      children: ayahs,
    );
  }
}
