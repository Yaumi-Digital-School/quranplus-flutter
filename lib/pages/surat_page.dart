import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';
import 'package:qurantafsir_flutter/shared/core/models/surat.dart';

class SuratPage extends StatelessWidget {
  final Surat surat;

  const SuratPage({Key? key, required this.surat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(54.0),
          child: AppBar(
            elevation: 2.5,
            foregroundColor: Colors.black,
            title: Text(surat.nameLatin),
            backgroundColor: backgroundColor,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAyatRow(context: context, surat: surat),
            ],
          ),
        ));
  }

  Widget _buildAyatRow({required BuildContext context, required Surat surat}) {
    Timer _timer = Timer(const Duration(milliseconds: 200), () {});

    return Expanded(
      child: ListView.builder(
          itemCount: surat.ayats.text.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onPanCancel: () => _timer.cancel(),
              onPanDown: (_) => {
                _timer = Timer(const Duration(milliseconds: 200), () {
                  showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25.0),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 100,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 8.0,
                              ),
                              Center(
                                child:
                                    Text("${surat.nameLatin} : ${index + 1}"),
                              ),
                              const SizedBox(
                                height: 24.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                        'images/icon_bookmark_outlined.png',
                                      ))),
                                    ),
                                    const SizedBox(
                                      width: 8.0,
                                    ),
                                    Text("Bookmark", style: bodyMedium2)
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      });
                })
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surat.ayats.text[index],
                    style: ayatFontStyle,
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      surat.translations.text[index],
                      style: bodyRegular3,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
