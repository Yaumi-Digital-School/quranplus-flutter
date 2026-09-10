import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/ayah_share_image.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/notifiers/surat_page_content_notifier.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/states/surat_page_content_state.dart';
import 'package:qurantafsir_flutter/pages/surat_page_v3/utils.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/core/models/quran_page.dart';
import 'package:qurantafsir_flutter/shared/core/services/quran_arabic_text_service.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

/// Test seams for the share execution phase, injected by [showAyahShareChooser].
///
/// In production both are null and the real OS share path runs (a temp PNG +
/// `Share.shareXFiles` for the image flow, `Share.share` for the text flow).
/// Tests pass non-null callbacks to capture the composed bytes/text instead of
/// invoking the platform share sheet.
class AyahShareSeams {
  const AyahShareSeams({this.onShareImage, this.onShareText});

  /// Image flow seam: receives the rendered PNG [bytes] and the accompanying
  /// share text instead of writing a temp file and opening the OS share sheet.
  final Future<void> Function(Uint8List bytes, String shareText)? onShareImage;

  /// Text flow seam: receives the composed plain-text share body instead of
  /// opening the OS share sheet.
  final Future<void> Function(String text)? onShareText;
}

/// Shared cached loader for the bundled Unicode Arabic (text-share flow). The
/// asset is parsed once and reused across every share, regardless of which
/// entry point (per-ayah sheet / detail sheet) triggered it.
final QuranArabicTextService _arabicTextService = QuranArabicTextService();

/// Global re-entrancy guard for the share EXECUTION phase (building the image /
/// composing the text / presenting the OS share sheet). It spans every entry
/// point so a second flow cannot start while one is still in flight, even
/// across different widgets. The chooser itself is a modal bottom sheet, so
/// opening a second chooser is already prevented by the navigator.
bool _shareFlowInFlight = false;

/// Opens the "Share as Image" / "Share as Text" chooser for [verse] and runs
/// the selected flow, preserving the exact behavior, strings and option keys of
/// the original detail-sheet implementation.
///
/// Contract / seams:
/// - [context] must be a context that stays mounted while the chooser is open
///   (for the per-ayah sheet, pass the OUTER widget's context, not the popped
///   sheet's). It is used to present the chooser, pop it, and resolve theme
///   colors for the option rows.
/// - [ref] must belong to a widget that stays mounted for the flow: it lazily
///   loads translation/tafsir via `ensureAyahDetailContent()` (so the
///   translation is present even when the reader disabled it) and reads the
///   content tables. Context-mounted checks guard every use after an await.
/// - [pageNumberInQuran] is the 1-based quran page the [verse] lives on; it
///   selects the `'Page<n>'` glyph font used to render the shared image.
/// - [sharePositionOrigin] is the iPad share-popover anchor; capture it from the
///   tapped widget's `RenderBox` before this call.
/// - [seams] injects test doubles for the execution phase (null in production).
/// - [onFlowStart] / [onFlowEnd] bracket the execution phase so a caller can
///   reflect the in-flight state in its own UI (e.g. disabling a share button).
///   [onFlowEnd] always runs once the flow settles, including on early return.
///
/// The chooser is opened fire-and-forget; the returned future completes once the
/// chooser has been presented (it does not await dismissal or the flow).
Future<void> showAyahShareChooser({
  required BuildContext context,
  required WidgetRef ref,
  required Verse verse,
  required int pageNumberInQuran,
  Rect? sharePositionOrigin,
  AyahShareSeams? seams,
  VoidCallback? onFlowStart,
  VoidCallback? onFlowEnd,
}) async {
  GeneralBottomSheet.showBaseBottomSheet(
    context: context,
    widgetChild: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildShareOption(
          context: context,
          optionKey: const Key('ayah_share_image_option'),
          icon: Icons.image_outlined,
          label: 'Share as Image',
          onTap: () {
            Navigator.of(context).pop();
            _runShareFlow(
              image: true,
              context: context,
              ref: ref,
              verse: verse,
              pageNumberInQuran: pageNumberInQuran,
              sharePositionOrigin: sharePositionOrigin,
              seams: seams,
              onFlowStart: onFlowStart,
              onFlowEnd: onFlowEnd,
            );
          },
        ),
        _buildShareOption(
          context: context,
          optionKey: const Key('ayah_share_text_option'),
          icon: Icons.notes,
          label: 'Share as Text',
          onTap: () {
            Navigator.of(context).pop();
            _runShareFlow(
              image: false,
              context: context,
              ref: ref,
              verse: verse,
              pageNumberInQuran: pageNumberInQuran,
              sharePositionOrigin: sharePositionOrigin,
              seams: seams,
              onFlowStart: onFlowStart,
              onFlowEnd: onFlowEnd,
            );
          },
        ),
      ],
    ),
  );
}

/// The "Shared via Quran Plus" tagline + store links appended to every shared
/// ayah, in both the text-share body and the image-share caption.
const String kAyahShareTagline =
    'Shared via Quran Plus\n'
    'Android : https://play.google.com/store/apps/details?id=com.yaumi.qurantafsir.id\n'
    'iOS : https://apps.apple.com/no/app/quranplus-tafsir-tadabbur/id6444388439';

/// Composes the plain-text share body. Blocks are separated by a blank line; a
/// null/empty Arabic or translation block is skipped (glyph codes are never used
/// as a fallback), while the reference and tagline blocks are always present:
///
///   <arabic>
///
///   <translation>
///
///   QS. <surah>: <verse>
///
///   Shared via Quran Plus
///   Android : https://play.google.com/store/apps/details?id=com.yaumi.qurantafsir.id
///   iOS : https://apps.apple.com/no/app/quranplus-tafsir-tadabbur/id6444388439
///
/// Pure (no I/O) so it can be unit-tested directly.
String composeAyahShareText({
  String? arabic,
  String? translation,
  required String reference,
}) {
  final List<String> blocks = <String>[];
  final String? trimmedArabic = arabic?.trim();
  if (trimmedArabic != null && trimmedArabic.isNotEmpty) {
    blocks.add(trimmedArabic);
  }
  final String? trimmedTranslation = translation?.trim();
  if (trimmedTranslation != null && trimmedTranslation.isNotEmpty) {
    blocks.add(trimmedTranslation);
  }
  blocks.add(reference);
  blocks.add(kAyahShareTagline);
  return blocks.join('\n\n');
}

/// Runs the selected share flow behind the global [_shareFlowInFlight] guard,
/// bracketing it with [onFlowStart]/[onFlowEnd] so the caller can mirror the
/// in-flight state. A no-op when a flow is already running.
Future<void> _runShareFlow({
  required bool image,
  required BuildContext context,
  required WidgetRef ref,
  required Verse verse,
  required int pageNumberInQuran,
  required Rect? sharePositionOrigin,
  required AyahShareSeams? seams,
  required VoidCallback? onFlowStart,
  required VoidCallback? onFlowEnd,
}) async {
  if (_shareFlowInFlight) return;
  _shareFlowInFlight = true;
  onFlowStart?.call();
  try {
    if (image) {
      await _shareAyahAsImage(
        context: context,
        ref: ref,
        verse: verse,
        pageNumberInQuran: pageNumberInQuran,
        sharePositionOrigin: sharePositionOrigin,
        seams: seams,
      );
    } else {
      await _shareAyahAsText(
        context: context,
        ref: ref,
        verse: verse,
        sharePositionOrigin: sharePositionOrigin,
        seams: seams,
      );
    }
  } finally {
    _shareFlowInFlight = false;
    onFlowEnd?.call();
  }
}

/// Image flow: render the branded PNG (best-effort logo) and hand it to the
/// share seam / OS share sheet.
Future<void> _shareAyahAsImage({
  required BuildContext context,
  required WidgetRef ref,
  required Verse verse,
  required int pageNumberInQuran,
  required Rect? sharePositionOrigin,
  required AyahShareSeams? seams,
}) async {
  // Ensure translation/tafsir tables exist even if the reader disabled them.
  await ref.read(suratPageContentProvider.notifier).ensureAyahDetailContent();
  if (!context.mounted) return;

  final SuratPageContentState content = ref.read(suratPageContentProvider);
  final String arabic = verse.words.map((Word w) => w.code).join(' ');
  final String surahName = surahNumberToSurahNameMap[verse.surahNumber] ?? '';
  final String reference = 'QS. $surahName: ${verse.verseNumber}';
  final String shareText = '$reference\n\n$kAyahShareTagline';

  // Load the brand mark best-effort; branding must never break sharing.
  final ui.Image? logo = await _loadLogo();
  Uint8List bytes;
  try {
    bytes = await buildAyahShareImage(
      arabicText: arabic,
      arabicFontFamily: 'Page$pageNumberInQuran',
      translation: _translationForVerse(content, verse),
      reference: reference,
      logo: logo,
    );
  } finally {
    logo?.dispose();
  }
  if (!context.mounted) return;

  final Future<void> Function(Uint8List bytes, String shareText)? seam =
      seams?.onShareImage;
  if (seam != null) {
    await seam(bytes, shareText);
    return;
  }

  final Directory dir = await getTemporaryDirectory();
  final File file = await File(
    '${dir.path}/ayah_${verse.id}.png',
  ).writeAsBytes(bytes);

  await Share.shareXFiles(
    <XFile>[XFile(file.path)],
    text: shareText,
    sharePositionOrigin: sharePositionOrigin,
  );
}

/// Text flow: share the Unicode Arabic (from the bundled Tanzil asset, never
/// glyph codes) on top, the translation below, then the reference tagline.
Future<void> _shareAyahAsText({
  required BuildContext context,
  required WidgetRef ref,
  required Verse verse,
  required Rect? sharePositionOrigin,
  required AyahShareSeams? seams,
}) async {
  // Ensure the translation table exists even if the reader disabled it.
  await ref.read(suratPageContentProvider.notifier).ensureAyahDetailContent();
  if (!context.mounted) return;

  final SuratPageContentState content = ref.read(suratPageContentProvider);
  final String surahName = surahNumberToSurahNameMap[verse.surahNumber] ?? '';
  final String reference = 'QS. $surahName: ${verse.verseNumber}';

  // The bundled Arabic asset lookup must never break sharing: on any failure
  // (e.g. a transient asset-read error) fall back to null, which
  // composeAyahShareText already treats as "skip this block" so the share still
  // proceeds with the translation and reference.
  String? arabic;
  try {
    arabic = await _arabicTextService.getArabicByVerseKey(verse.verseKey);
  } catch (_) {
    arabic = null;
  }
  final String text = composeAyahShareText(
    arabic: arabic,
    translation: _translationForVerse(content, verse),
    reference: reference,
  );
  if (!context.mounted) return;

  final Future<void> Function(String text)? seam = seams?.onShareText;
  if (seam != null) {
    await seam(text);
    return;
  }

  await Share.share(text, sharePositionOrigin: sharePositionOrigin);
}

/// One chooser row: an icon + label opening a share flow. Themed off [context].
Widget _buildShareOption({
  required BuildContext context,
  required Key optionKey,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  final Color primary = Theme.of(context).colorScheme.primary;
  return InkWell(
    key: optionKey,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: <Widget>[
          Icon(icon, color: primary),
          const SizedBox(width: 16),
          Text(label, style: QPTextStyle.getSubHeading4Regular(context)),
        ],
      ),
    ),
  );
}

/// Loads and decodes `images/logogram.png` for the branded image; returns null
/// on any failure so sharing proceeds without the logo. The caller disposes it.
Future<ui.Image?> _loadLogo() async {
  try {
    final ByteData data = await rootBundle.load('images/logogram.png');
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  } catch (_) {
    return null;
  }
}

/// The Indonesian translation cell for [verse], or null when the table is
/// missing/short or the cell is empty.
String? _translationForVerse(SuratPageContentState content, Verse verse) {
  final List<List<String>>? table = content.translations;
  if (table == null) return null;
  final int s = verse.surahNumberInIndex;
  final int a = verse.verseNumberInIndex;
  if (s < 0 || s >= table.length) return null;
  if (a < 0 || a >= table[s].length) return null;
  final String value = table[s][a];
  return value.isEmpty ? null : value;
}
