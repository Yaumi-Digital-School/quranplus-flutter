import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Renders a shareable PNG for a single ayah: the Arabic glyphs (page font) on
/// top, the Indonesian translation below, and a "QS. <surah>: <verse>"
/// reference line at the bottom.
///
/// Headless (no widget tree): each block is laid out with a [TextPainter] and
/// painted onto a [ui.PictureRecorder] canvas, so it can run straight from a
/// button handler. The canvas is intentionally theme-independent (white
/// background, near-black text) so shared images look the same regardless of
/// the in-app theme.
///
/// [arabicText] are the page glyph codes (joined `word.code`s) and
/// [arabicFontFamily] must be the matching `'Page<n>'` family — the app ships
/// no Unicode Arabic, so the glyphs are meaningless in any other font.
Future<Uint8List> buildAyahShareImage({
  required String arabicText,
  required String arabicFontFamily,
  String? translation,
  required String reference,
}) async {
  const double width = 1080;
  const double padding = 72;
  const double contentWidth = width - padding * 2;
  const double gapAfterArabic = 40;
  const double gapBeforeReference = 48;

  const ui.Color background = ui.Color(0xFFFFFFFF);
  const ui.Color arabicColor = ui.Color(0xFF1A1A1A);
  const ui.Color translationColor = ui.Color(0xFF3D3D3D);
  const ui.Color referenceColor = ui.Color(0xFF8A8A8A);

  // minWidth == maxWidth pins each block to the full content box so the Arabic
  // block right-aligns against the right edge (not just within its own run).
  final TextPainter arabicPainter = TextPainter(
    text: TextSpan(
      text: arabicText,
      style: TextStyle(
        color: arabicColor,
        fontFamily: arabicFontFamily,
        fontSize: 56,
        height: 1.8,
      ),
    ),
    textDirection: TextDirection.rtl,
    textAlign: TextAlign.right, // Arabic reads right-to-left.
  )..layout(minWidth: contentWidth, maxWidth: contentWidth);

  final String? trimmedTranslation = translation?.trim();
  TextPainter? translationPainter;
  if (trimmedTranslation != null && trimmedTranslation.isNotEmpty) {
    translationPainter = TextPainter(
      text: TextSpan(
        text: trimmedTranslation,
        style: const TextStyle(
          color: translationColor,
          fontSize: 34,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left, // Indonesian reads left-to-right.
    )..layout(minWidth: contentWidth, maxWidth: contentWidth);
  }

  final TextPainter referencePainter = TextPainter(
    text: TextSpan(
      text: reference,
      style: const TextStyle(
        color: referenceColor,
        fontSize: 30,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.left,
  )..layout(minWidth: contentWidth, maxWidth: contentWidth);

  double height = padding + arabicPainter.height;
  if (translationPainter != null) {
    height += gapAfterArabic + translationPainter.height;
  }
  height += gapBeforeReference + referencePainter.height + padding;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, width, height),
  );
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width, height),
    ui.Paint()..color = background,
  );

  double dy = padding;
  arabicPainter.paint(canvas, ui.Offset(padding, dy));
  dy += arabicPainter.height;

  if (translationPainter != null) {
    dy += gapAfterArabic;
    translationPainter.paint(canvas, ui.Offset(padding, dy));
    dy += translationPainter.height;
  }

  dy += gapBeforeReference;
  referencePainter.paint(canvas, ui.Offset(padding, dy));

  final ui.Image image = await recorder.endRecording().toImage(
    width.ceil(),
    height.ceil(),
  );
  try {
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return bytes!.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
