import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/ayah_share.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/full_page_ayah_utils.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';

/// Bottom sheet showing a single ayah's Arabic (page glyph font, centered),
/// translation and tafsir, with a share button and a sticky footer stepping to
/// the previous/next ayah in global quran order. When the adjacent ayah lives
/// on a different mushaf page the footer shows a double chevron and stepping
/// also slides the mushaf PageView behind the sheet. Opened from a 1-second
/// hold in full-page mode.
class AyahDetailBottomSheet extends ConsumerStatefulWidget {
  const AyahDetailBottomSheet({
    super.key,
    required this.initialAyahId,
    this.onShare,
    this.onShareText,
  });

  final int initialAyahId;

  /// Test seam for the image flow: invoked with the rendered PNG [bytes] and the
  /// share text instead of writing a temp file and opening the OS share sheet.
  /// Null in production (the real share path runs).
  final Future<void> Function(Uint8List bytes, String shareText)? onShare;

  /// Test seam for the text flow: invoked with the composed plain-text share
  /// body instead of opening the OS share sheet. Null in production (the real
  /// share path runs).
  final Future<void> Function(String text)? onShareText;

  @override
  ConsumerState<AyahDetailBottomSheet> createState() =>
      _AyahDetailBottomSheetState();
}

class _AyahDetailBottomSheetState extends ConsumerState<AyahDetailBottomSheet> {
  late int _currentAyahId;
  bool _isLoadingDetail = true;
  // Guards against a second share starting while the first is still building its
  // image / presenting the OS share sheet (the button stays visible meanwhile).
  bool _isSharing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentAyahId = widget.initialAyahId;
    _loadDetail();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    // Loads translation/tafsir on demand without touching reading settings.
    await ref.read(suratPageContentProvider.notifier).ensureAyahDetailContent();
    if (!mounted) return;
    setState(() => _isLoadingDetail = false);
  }

  void _goToAdjacent({required bool next}) {
    final List<QuranPage> pages =
        ref.read(suratPageContentProvider).pages ?? const <QuranPage>[];
    final ({Verse verse, int pageIdx})? current = findVerseById(
      pages,
      _currentAyahId,
    );
    final ({Verse verse, int pageIdx})? adjacent = adjacentVerse(
      pages,
      _currentAyahId,
      next: next,
    );
    if (adjacent == null) return;

    setState(() => _currentAyahId = adjacent.verse.id);
    // Start the new ayah at the top rather than inheriting the old scroll offset.
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    // Keep the mushaf behind the sheet in sync.
    ref
        .read(suratPageNavigationProvider.notifier)
        .setHighlightedAyah(adjacent.verse.id);

    // When the adjacent ayah sits on a different mushaf page, slide the PageView
    // behind the sheet to it. The PageView's onPageChanged keeps nav/bookmark/
    // habit state in sync, so we must not update it manually here.
    if (current != null && adjacent.pageIdx != current.pageIdx) {
      final PageController? pageController = ref
          .read(suratPageNavigationProvider)
          .pageController;
      if (pageController != null && pageController.hasClients) {
        pageController.animateToPage(
          adjacent.pageIdx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Tapping the share button: resolve the current verse, capture the iPad
  /// popover anchor (the button context may unmount while the chooser is open),
  /// then delegate to the shared chooser + image/text share flow. The chooser's
  /// execution phase is wired back to [_isSharing] so the button stays disabled
  /// while a share is in flight.
  void _onShare(BuildContext buttonContext) {
    // Re-entrancy guard: ignore taps while a share is already in flight so a
    // fast double-tap cannot open a second chooser or share twice.
    if (_isSharing) return;

    final List<QuranPage> pages =
        ref.read(suratPageContentProvider).pages ?? const <QuranPage>[];
    final ({Verse verse, int pageIdx})? resolved = findVerseById(
      pages,
      _currentAyahId,
    );
    if (resolved == null) return;

    // Capture the popover anchor before any navigation/await: iPad needs it,
    // and the button context can unmount while the chooser/image renders.
    final RenderBox? box = buttonContext.findRenderObject() as RenderBox?;
    final Rect? sharePositionOrigin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    showAyahShareChooser(
      context: context,
      ref: ref,
      verse: resolved.verse,
      pageNumberInQuran: resolved.pageIdx + 1,
      sharePositionOrigin: sharePositionOrigin,
      seams: AyahShareSeams(
        onShareImage: widget.onShare,
        onShareText: widget.onShareText,
      ),
      onFlowStart: () {
        if (mounted) setState(() => _isSharing = true);
      },
      onFlowEnd: () {
        if (mounted) setState(() => _isSharing = false);
      },
    );
  }

  String? _translationFor(SuratPageContentState content, Verse verse) =>
      _cellAt(content.translations, verse);

  String? _tafsirFor(SuratPageContentState content, Verse verse) =>
      _cellAt(content.tafsirs, verse);

  String? _cellAt(List<List<String>>? table, Verse verse) {
    if (table == null) return null;
    final int s = verse.surahNumberInIndex;
    final int a = verse.verseNumberInIndex;
    if (s < 0 || s >= table.length) return null;
    if (a < 0 || a >= table[s].length) return null;
    final String value = table[s][a];
    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    final SuratPageContentState content = ref.watch(suratPageContentProvider);
    final List<QuranPage> pages = content.pages ?? const <QuranPage>[];
    final ({Verse verse, int pageIdx})? resolved = findVerseById(
      pages,
      _currentAyahId,
    );

    // ~90% of the viewport including BaseWidgetBottomSheet's chrome
    // (drag handle + paddings, ~73px), so the sheet itself lands at 90%.
    final double sheetHeight = MediaQuery.of(context).size.height * 0.9 - 73;

    if (resolved == null) {
      return SizedBox(height: sheetHeight);
    }

    final Verse verse = resolved.verse;
    final int page = resolved.pageIdx + 1;
    final Color primary = Theme.of(context).colorScheme.primary;

    final String arabic = verse.words.map((Word w) => w.code).join(' ');
    final String? translation = _translationFor(content, verse);
    final String? tafsir = _tafsirFor(content, verse);

    return SizedBox(
      height: sheetHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    // Builder so the handler can read the button's own RenderBox
                    // for the iPad share-sheet popover anchor.
                    child: Builder(
                      builder: (BuildContext buttonContext) => IconButton(
                        key: const Key('ayah_detail_share'),
                        icon: const Icon(Icons.share_outlined),
                        color: primary,
                        // Disabled while loading or mid-share; the disabled
                        // state doubles as in-flight feedback.
                        onPressed: _isLoadingDetail || _isSharing
                            ? null
                            : () => _onShare(buttonContext),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      arabic,
                      key: const Key('ayah_detail_arabic'),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Page$page',
                        fontSize: 22,
                        height: 1.8,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingDetail)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...<Widget>[
                    if (translation != null)
                      _buildSection(
                        context: context,
                        label: 'Terjemahan',
                        body: translation,
                      ),
                    if (tafsir != null)
                      _buildSection(
                        context: context,
                        label: 'Tafsir Kemenag',
                        body: tafsir,
                      ),
                  ],
                ],
              ),
            ),
          ),
          _buildFooter(
            context: context,
            verse: verse,
            pages: pages,
            currentPageIdx: resolved.pageIdx,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String label,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: QPTextStyle.getBody2SemiBold(context).copyWith(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteRoot,
                light: QPColors.neutral600,
                brown: QPColors.brownModeHeavy,
                context: context,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: QPTextStyle.getBody2Regular(context).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter({
    required BuildContext context,
    required Verse verse,
    required List<QuranPage> pages,
    required int currentPageIdx,
  }) {
    final ({Verse verse, int pageIdx})? previous = adjacentVerse(
      pages,
      _currentAyahId,
      next: false,
    );
    final ({Verse verse, int pageIdx})? next = adjacentVerse(
      pages,
      _currentAyahId,
      next: true,
    );

    final Color enabledColor = Theme.of(context).colorScheme.primary;
    final String surahName = surahNumberToSurahNameMap[verse.surahNumber] ?? '';

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: QPColors.getColorBasedTheme(
              dark: QPColors.darkModeFair,
              light: QPColors.whiteRoot,
              brown: QPColors.brownModeFair,
              context: context,
            ),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          IconButton(
            key: const Key('ayah_detail_prev'),
            icon: Icon(_chevronIcon(previous, currentPageIdx, next: false)),
            color: enabledColor,
            onPressed: previous != null ? () => _goToAdjacent(next: false) : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$surahName:${verse.verseNumber}',
                key: const Key('ayah_detail_label'),
                style: QPTextStyle.getSubHeading4SemiBold(context),
              ),
            ),
          ),
          IconButton(
            key: const Key('ayah_detail_next'),
            icon: Icon(_chevronIcon(next, currentPageIdx, next: true)),
            color: enabledColor,
            onPressed: next != null ? () => _goToAdjacent(next: true) : null,
          ),
        ],
      ),
    );
  }

  /// Chevron for one footer side: a double chevron when the adjacent ayah lives
  /// on a different mushaf page (stepping there also slides the page behind the
  /// sheet), a single chevron otherwise. Falls back to a single chevron when
  /// there is no adjacent ayah — the button is disabled in that case anyway.
  IconData _chevronIcon(
    ({Verse verse, int pageIdx})? adjacent,
    int currentPageIdx, {
    required bool next,
  }) {
    final bool crossesPage =
        adjacent != null && adjacent.pageIdx != currentPageIdx;
    if (next) {
      return crossesPage
          ? Icons.keyboard_double_arrow_right
          : Icons.chevron_right;
    }
    return crossesPage ? Icons.keyboard_double_arrow_left : Icons.chevron_left;
  }
}
