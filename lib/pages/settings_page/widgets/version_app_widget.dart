import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class VersionAppWidget extends StatefulWidget {
  const VersionAppWidget({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<VersionAppWidget> createState() => _VersionAppWidget();
}

class _VersionAppWidget extends State<VersionAppWidget> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _packageInfo == null ? '' : _packageInfo!.version,
      style: QPTextStyle.getSubHeading3Regular(context).copyWith(
        color: QPColors.getColorBasedTheme(
          dark: QPColors.blackFair,
          light: QPColors.blackFair,
          brown: QPColors.brownModeMassive,
          context: context,
        ),
      ),
    );
  }
}
