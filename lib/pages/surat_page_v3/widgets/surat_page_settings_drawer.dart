import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_theme_data.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/providers.dart';
import 'package:qurantafsir_flutter/shared/core/state_notifiers/theme_state_notifier.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';
import 'package:qurantafsir_flutter/widgets/change_theme_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/general_bottom_sheet.dart';
import 'package:qurantafsir_flutter/widgets/theme_box_option_widget.dart';

enum ContentType {
  arab,
  translation,
  tafsir,
  latins,
}

class SuratPageSettingsDrawer extends ConsumerStatefulWidget {
  const SuratPageSettingsDrawer({
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
  final Function() onTapAdd;
  final Function() onTapMinus;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SuratPageSettingsDrawerState();
}

class _SuratPageSettingsDrawerState
    extends ConsumerState<SuratPageSettingsDrawer> {
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
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildContentSection(),
            _buildDivider(),
            _buildChangeFontSize(),
            _buildDivider(),
            _buildSelectTheme(),
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
        ListTile(
          title: Text(
            'Content',
            style: QPTextStyle.getSubHeading3SemiBold(context).copyWith(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.brandFair,
                brown: QPColors.brandHeavy,
                context: context,
              ),
            ),
          ),
        ),
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _buildCheckbox(
                  text: 'Tafsir',
                  contentType: ContentType.tafsir,
                  context: context,
                ),
                _buildCheckbox(
                  text: 'Terjemahan',
                  contentType: ContentType.translation,
                  context: context,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                _buildCheckbox(
                  text: 'Latin',
                  contentType: ContentType.latins,
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String text,
    required ContentType contentType,
    required BuildContext context,
  }) {
    final Color checkboxDecorationColor = QPColors.getColorBasedTheme(
      dark: QPColors.whiteFair,
      brown: QPColors.blackHeavy,
      light: QPColors.blackHeavy,
      context: context,
    );

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
            checkColor: checkboxDecorationColor,
            activeColor: Theme.of(context).dialogBackgroundColor,
            side: MaterialStateBorderSide.resolveWith(
              (states) => BorderSide(
                width: 1.0,
                color: checkboxDecorationColor,
              ),
            ),
          ),
          Text(
            text,
            style: QPTextStyle.getSubHeading3Regular(context).copyWith(
              color: checkboxDecorationColor,
            ),
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
            style: QPTextStyle.getSubHeading3SemiBold(context).copyWith(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.brandFair,
                brown: QPColors.brandHeavy,
                context: context,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => widget.onTapMinus(),
              child: _buildButtonFontSize(
                neutral200,
                Icons.remove,
                secondaryGreen300,
              ),
            ),
            Text(
              '${widget.fontSize}x',
              style: const TextStyle(
                color: neutral700,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => widget.onTapAdd(),
              child: _buildButtonFontSize(brokenWhite, Icons.add, darkGreen),
            ),
          ],
        ),
        const SizedBox(
          height: 18,
        ),
      ],
    );
  }

  Widget _buildButtonFontSize(
    Color colorButton,
    IconData iconButton,
    Color colorIcon,
  ) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: colorButton,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff000000).withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 0.9),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          iconButton,
          color: colorIcon,
        ),
      ),
    );
  }

  Widget _buildSelectTheme() {
    final ThemeStateNotifier themeMode = ref.read(themeProvider.notifier);
    final QPThemeMode theme = ref.read(themeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 24,
          ),
          Text(
            'Selected Theme',
            style: QPTextStyle.getSubHeading3SemiBold(context).copyWith(
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.brandFair,
                brown: QPColors.brandHeavy,
                context: context,
              ),
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          SizedBox(
            width: 98,
            child: ThemeBoxOptionWidget(
              theme: theme.label,
              colorParam: themeMode.getThemeOptionColor(),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ButtonSecondary(
            label: 'Change Theme',
            onTap: () {
              GeneralBottomSheet.showBaseBottomSheet(
                context: context,
                widgetChild: const ChangeThemeBottomSheet(),
              );
            },
          ),
        ],
      ),
    );
  }
}
