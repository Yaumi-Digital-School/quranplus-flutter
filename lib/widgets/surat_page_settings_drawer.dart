import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

enum ContentType {
  arab,
  translation,
  tafsir,
  latins,
}

class SuratPageSettingsDrawer extends StatefulWidget {
  SuratPageSettingsDrawer({
    Key? key,
    required this.onTapTranslation,
    required this.onTapTafsir,
    required this.onTapLatins,
    required this.onTapAdd,
    required this.onTapMinus,
    required this.fontSize,
    this.isWithTranslation,
    this.isWithTafsir,
    this.isWithLatins,
  }) : super(key: key);

  final bool? isWithTranslation;
  final bool? isWithTafsir;
  final bool? isWithLatins;
  final int fontSize;

  final ValueSetter<bool> onTapTranslation;
  final ValueSetter<bool> onTapTafsir;
  final ValueSetter<bool> onTapLatins;
  final Function(int) onTapAdd;
  final Function(int) onTapMinus;

  @override
  State<StatefulWidget> createState() => _SuratPageSettingsDrawerState();
}

class _SuratPageSettingsDrawerState extends State<SuratPageSettingsDrawer> {
  late bool isWithTranslation;
  late bool isWithTafsir;
  late bool isWithLatins;

  @override
  void initState() {
    isWithTranslation = widget.isWithTranslation ?? false;
    isWithTafsir = widget.isWithTafsir ?? false;
    isWithLatins = widget.isWithLatins ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[_buildContentSection(), _buildChangeFontSize()],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: Divider(
        height: 10,
        color: neutral400,
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            'Content',
            style: titleDrawerBold,
          ),
        ),
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _buildCheckbox(
                  text: 'Tafsir',
                  contentType: ContentType.tafsir,
                ),
                _buildCheckbox(
                  text: 'Terjemahan',
                  contentType: ContentType.translation,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                _buildCheckbox(
                  text: 'Latin',
                  contentType: ContentType.latins,
                ),
              ],
            ),
          ],
        ),
        _buildDivider(),
      ],
    );
  }

  Widget _buildCheckbox({
    required String text,
    required ContentType contentType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 21),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: contentType == ContentType.translation
                ? isWithTranslation
                : (contentType == ContentType.tafsir
                    ? isWithTafsir
                    : isWithLatins),
            onChanged: (value) {
              bool res = value ?? false;

              setState(() {
                switch (contentType) {
                  case ContentType.latins:
                    isWithLatins = res;
                    widget.onTapLatins(res);
                    break;
                  case ContentType.translation:
                    isWithTranslation = res;
                    widget.onTapTranslation(res);
                    break;
                  case ContentType.tafsir:
                    isWithTafsir = res;
                    widget.onTapTafsir(res);
                    break;
                  default:
                    break;
                }
              });
            },
            checkColor: neutral900,
            activeColor: backgroundColor,
            side: MaterialStateBorderSide.resolveWith(
              (states) => const BorderSide(
                width: 1.0,
                color: neutral900,
              ),
            ),
          ),
          Text(
            text,
            style: bodyDrawerRegular,
          ),
        ],
      ),
    );
  }

  Widget _buildChangeFontSize() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            'Font Size',
            style: titleDrawerBold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
                onTap: () => widget.onTapMinus(widget.fontSize),
                child: _buildButtonFontSize(
                    neutral200, Icons.remove, secondaryGreen300)),
            Text(
              '${widget.fontSize}x',
              style: TextStyle(
                  color: neutral700, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            GestureDetector(
                onTap: () => widget.onTapAdd(widget.fontSize),
                child: _buildButtonFontSize(brokenWhite, Icons.add, darkGreen))
          ],
        )
      ],
    );
  }

  Widget _buildButtonFontSize(
      Color colorButton, IconData iconButton, Color colorIcon) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorButton,
          boxShadow: [
            BoxShadow(
                color: Color(0xff000000).withOpacity(0.1),
                blurRadius: 6,
                spreadRadius: 0,
                offset: Offset(0, 0.9))
          ]),
      child: Center(
          child: Icon(
        iconButton,
        color: colorIcon,
      )),
    );
  }
}
