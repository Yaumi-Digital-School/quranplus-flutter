import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/full_page_ayah_utils.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';

/// Bottom sheet showing a single ayah's Arabic (page glyph font, centered),
/// translation and tafsir, with a sticky footer stepping to the previous/next
/// ayah in global quran order. Opened from a 1-second hold in full-page mode.
class AyahDetailBottomSheet extends ConsumerStatefulWidget {
  const AyahDetailBottomSheet({super.key, required this.initialAyahId});

  final int initialAyahId;

  @override
  ConsumerState<AyahDetailBottomSheet> createState() =>
      _AyahDetailBottomSheetState();
}

class _AyahDetailBottomSheetState extends ConsumerState<AyahDetailBottomSheet> {
  late int _currentAyahId;
  bool _isLoadingDetail = true;

  @override
  void initState() {
    super.initState();
    _currentAyahId = widget.initialAyahId;
    _loadDetail();
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
    final ({Verse verse, int pageIdx})? adjacent = adjacentVerse(
      pages,
      _currentAyahId,
      next: next,
    );
    if (adjacent == null) return;

    setState(() => _currentAyahId = adjacent.verse.id);
    // Keep the mushaf behind the sheet in sync.
    ref
        .read(suratPageNavigationProvider.notifier)
        .setHighlightedAyah(adjacent.verse.id);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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
          _buildFooter(context: context, verse: verse, pages: pages),
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
  }) {
    final bool hasPrevious =
        adjacentVerse(pages, _currentAyahId, next: false) != null;
    final bool hasNext =
        adjacentVerse(pages, _currentAyahId, next: true) != null;

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
            icon: const Icon(Icons.chevron_left),
            color: enabledColor,
            onPressed: hasPrevious ? () => _goToAdjacent(next: false) : null,
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
            icon: const Icon(Icons.chevron_right),
            color: enabledColor,
            onPressed: hasNext ? () => _goToAdjacent(next: true) : null,
          ),
        ],
      ),
    );
  }
}
