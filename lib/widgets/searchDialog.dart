import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class GeneralSearchDialog {
  Future _searchDialog(BuildContext context, Widget widgetChild) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: brokenWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width,
              child: widgetChild),
        );
      },
    );
  }
}
