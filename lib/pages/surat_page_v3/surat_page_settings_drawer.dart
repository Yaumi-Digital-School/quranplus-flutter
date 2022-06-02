import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

enum ContentType {
  arab,
  translation,
  tafsir,
}

class SuratPageSettingsDrawer extends StatefulWidget {
  const SuratPageSettingsDrawer({
    Key? key,
    required this.onTapTranslation,
    required this.onTapTafsir,
    this.isWithTranslation,
    this.isWithTafsir,
  }) : super(key: key);

  final bool? isWithTranslation;
  final bool? isWithTafsir;

  final ValueSetter<bool> onTapTranslation;
  final ValueSetter<bool> onTapTafsir;

  @override
  State<StatefulWidget> createState() => _SuratPageSettingsDrawerState();
}

class _SuratPageSettingsDrawerState extends State<SuratPageSettingsDrawer> {
  late bool isWithTranslation;
  late bool isWithTafsir;

  @override
  void initState() {
    isWithTranslation = widget.isWithTranslation ?? false;
    isWithTafsir = widget.isWithTafsir ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildContentSection(),
          ],
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
        const ListTile(
          title: Text(
            'Content',
            style: TextStyle(
              fontSize: 14,
              color: darkGreen,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            _buildCheckbox(
              text: 'Terjemahan',
              contentType: ContentType.translation,
            ),
            _buildCheckbox(
              text: 'Tafsir',
              contentType: ContentType.tafsir,
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
                : isWithTafsir,
            onChanged: (value) {
              bool res = value ?? false;

              setState(() {
                switch (contentType) {
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
            style: const TextStyle(
              color: secondaryGreen,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
