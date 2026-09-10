import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

/// Per-ayah long-press sheet CTA that starts the share flow. Mirrors
/// [FavoriteAyahCTA]'s row style (same LTRB(18,18,0,18) padding, 24px leading
/// icon + 10px gap, label in [captionSemiBold1]) so the two rows align in the
/// sheet.
///
/// Seam: [onTap] receives this row's own global [Rect] as the iPad
/// share-popover anchor (null when the box has not been laid out yet), captured
/// before the caller pops the sheet — after the pop this context unmounts and
/// the render box is gone. The widget is purely presentational: it never touches
/// navigation or providers, leaving the caller to pop the sheet and open the
/// share chooser with that anchor.
class ShareAyahCTA extends StatelessWidget {
  const ShareAyahCTA({super.key, required this.onTap});

  final void Function(Rect? sharePositionOrigin) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('ayah_item_share_cta'),
      // Opaque so the whole row (including the empty space after the label) is a
      // valid tap target, not just the icon/label glyphs.
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        final Rect? origin = box != null && box.hasSize
            ? box.localToGlobal(Offset.zero) & box.size
            : null;
        onTap(origin);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 0, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.share_outlined,
              size: 24,
              color: captionSemiBold1.color,
            ),
            const SizedBox(width: 10),
            Text('Share', style: captionSemiBold1),
          ],
        ),
      ),
    );
  }
}
