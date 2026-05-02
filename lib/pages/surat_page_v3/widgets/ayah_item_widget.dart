import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_bookmark_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_habit_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_navigation_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/shared/constants/connectivity_status_enum.dart';
import 'package:qurantafsir_flutter/shared/constants/icon.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/providers/internet_connection_provider.dart';
import 'package:qurantafsir_flutter/widgets/audio_bottom_sheet/audio_bottom_sheet_widget.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/horizontal_divider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'widgets.dart';

class AyahItemWidget extends ConsumerWidget {
  const AyahItemWidget({
    super.key,
    required this.verse,
    required this.useDivider,
    required this.fontSize,
    required this.pageNumberInQuran,
    required this.orientation,
    required this.scrollController,
    required this.startPageInIndex,
  });

  final Verse verse;
  final bool useDivider;
  final double fontSize;
  final int pageNumberInQuran;
  final Orientation orientation;
  final AutoScrollController scrollController;
  final int startPageInIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(suratPageNavigationProvider);
    final contentState = ref.watch(suratPageContentProvider);
    final navNotifier = ref.read(suratPageNavigationProvider.notifier);
    final habitNotifier = ref.read(suratPageHabitProvider.notifier);
    final bookmarkNotifier = ref.read(suratPageBookmarkProvider.notifier);
    final connectivityStatus = ref.watch(internetConnectionStatusProvider);

    String allVerses = '';
    String fontFamilyPage = 'Page$pageNumberInQuran';

    bool useBasmalahBeforeAyah =
        navState.visibleSuratName != "At-Taubah" && verse.verseNumber == 1;

    String? translation = contentState
        .translations?[verse.surahNumberInIndex][verse.verseNumberInIndex];
    String? latin = contentState
        .latins?[verse.surahNumberInIndex][verse.verseNumberInIndex];
    String? tafsir = contentState
        .tafsirs?[verse.surahNumberInIndex][verse.verseNumberInIndex];
    bool isWithTranslations =
        contentState.readingSettings!.isWithTranslations;
    bool isWithTafsirs = contentState.readingSettings!.isWithTafsirs;
    bool isWithLatins = contentState.readingSettings!.isWithLatins;
    bool isFavorited = bookmarkNotifier.isAyahFavorited(verse.id);
    ValueKey key = ValueKey(verse.surahNameAndAyatKey);

    for (Word word in verse.words) {
      allVerses += '${word.code} ';
    }

    return AutoScrollTag(
      key: key,
      controller: pageNumberInQuran - 1 == startPageInIndex
          ? scrollController
          : AutoScrollController(),
      index: verse.id,
      child: VisibilityDetector(
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 1) {
            navNotifier.updateVisibleSurah(verse.surahNumber);
            navNotifier.updateVisibleJuz(verse.juzNumber);
          }
        },
        key: key,
        child: Column(
          children: <Widget>[
            if (useBasmalahBeforeAyah)
              BasmalahWidget(orientation: orientation),
            _buildAyahContent(
              context,
              allVerses,
              fontFamilyPage,
              isFavorited,
              bookmarkNotifier,
              habitNotifier,
              connectivityStatus,
            ),
            if (isWithLatins)
              _buildLatinSection(context, latin!, contentState),
            if (isWithTranslations)
              _buildTranslationSection(context, translation!, contentState),
            if (isWithTafsirs)
              _buildTafsirSection(context, tafsir!, contentState),
            if (contentState.availableAyahTadabburs[verse.surahNumber] !=
                    null &&
                contentState.availableAyahTadabburs[verse.surahNumber]!
                    .contains(verse.verseNumber))
              const Align(
                alignment: Alignment.centerRight,
                child: TadabburAvailableFlag(),
              ),
            if (useDivider)
              const Padding(
                padding:
                    EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: HorizontalDivider(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahContent(
    BuildContext context,
    String allVerses,
    String fontFamilyPage,
    bool isFavorited,
    SuratPageBookmarkNotifier bookmarkNotifier,
    SuratPageHabitNotifier habitNotifier,
    ConnectivityStatus connectivityStatus,
  ) {
    return GestureDetector(
      onLongPress: () {
        GeneralBottomSheet().showGeneralBottomSheet(
          context,
          verse.surahNameAndAyatKey,
          FavoriteAyahCTA(
            onTap: () async {
              await bookmarkNotifier.toggleFavoriteAyah(
                surahNumber: verse.surahNumber,
                ayahNumber: verse.verseNumber,
                ayahID: verse.id,
                page: pageNumberInQuran,
              );
            },
            isFavorited: bookmarkNotifier.isAyahFavorited(verse.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isFavorited)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(StoredIcon.iconFavorite.path),
                      ),
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    color: QPColors.getColorBasedTheme(
                      dark: QPColors.blackFair,
                      light: QPColors.blackFair,
                      brown: QPColors.brownModeHeavy,
                      context: context,
                    ),
                    padding: const EdgeInsets.all(0),
                    alignment: Alignment.centerLeft,
                    icon: const Icon(Icons.play_circle_outline),
                    iconSize: 20,
                    onPressed: () => _playOnAyah(
                      context,
                      habitNotifier,
                      connectivityStatus,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      allVerses,
                      style: TextStyle(
                        fontFamily: fontFamilyPage,
                        fontSize: fontSize,
                        height: 1.6,
                        wordSpacing: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatinSection(
    BuildContext context,
    String latin,
    SuratPageContentState contentState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          latin,
          style: QPTextStyle.getDescription1Regular(context).copyWith(
            fontSize: orientation == Orientation.landscape
                ? contentState.readingSettings!.valueFontSizeLandscape
                : contentState.readingSettings?.valueFontSize,
            color: QPColors.getColorBasedTheme(
              dark: QPColors.blackSoft,
              light: QPColors.neutral600,
              brown: QPColors.brownModeMassive,
              context: context,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationSection(
    BuildContext context,
    String translation,
    SuratPageContentState contentState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          translation,
          style: QPTextStyle.getDescription1Regular(context).copyWith(
            height: 1.5,
            fontSize: contentState.readingSettings?.valueFontSize,
          ),
        ),
      ),
    );
  }

  Widget _buildTafsirSection(
    BuildContext context,
    String tafsir,
    SuratPageContentState contentState,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QPColors.getColorBasedTheme(
          dark: QPColors.darkModeFair,
          light: QPColors.whiteSoft,
          brown: QPColors.brownModeHeavy,
          context: context,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tafsir,
                style: QPTextStyle.getDescription1Regular(context).copyWith(
                  height: 1.5,
                  fontSize: contentState.readingSettings?.valueFontSize,
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.whiteFair,
                    light: QPColors.blackFair,
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tafsir Ringkasan Kemenag',
                style: QPTextStyle.getDescription1Regular(context).copyWith(
                  color: QPColors.getColorBasedTheme(
                    dark: QPColors.blackSoft,
                    light: Colors.black.withValues(alpha: 0.5),
                    brown: QPColors.brownModeMassive,
                    context: context,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playOnAyah(
    BuildContext context,
    SuratPageHabitNotifier habitNotifier,
    ConnectivityStatus connectivityStatus,
  ) async {
    if (connectivityStatus == ConnectivityStatus.isDisconnected &&
        context.mounted) {
      GeneralBottomSheet.showNoInternetBottomSheet(
        context,
        () {
          Navigator.pop(context);
          _playOnAyah(context, habitNotifier, connectivityStatus);
        },
      );
      return;
    }

    habitNotifier.playOnAyah(verse);
    if (context.mounted) {
      GeneralBottomSheet.showBaseBottomSheet(
        context: context,
        widgetChild: const AudioBottomSheetWidget(),
      );
    }
  }
}
