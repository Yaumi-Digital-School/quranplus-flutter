import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/Icon.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class FavoriteAyahCTA extends StatefulWidget {
  const FavoriteAyahCTA({
    Key? key,
    required this.onTap,
    this.isFavorited = false,
  }) : super(key: key);

  final VoidCallback onTap;
  final bool isFavorited;

  @override
  State<FavoriteAyahCTA> createState() => _FavoriteAyahCTAState();
}

class _FavoriteAyahCTAState extends State<FavoriteAyahCTA> {
  late bool isFavorited;

  @override
  void initState() {
    isFavorited = widget.isFavorited;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() {
          isFavorited = !isFavorited;
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          0,
          18,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    isFavorited
                        ? IconPath.iconFavorite
                        : IconPath.iconFavoriteInactive,
                  ),
                ),
              ),
            ),
            Text(
              isFavorited ? 'Remove from Favorite' : 'Add to Favorite',
              style: captionSemiBold1,
            ),
          ],
        ),
      ),
    );
  }
}
