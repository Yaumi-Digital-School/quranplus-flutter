import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurantafsir_flutter/pages/read_tadabbur/read_tadabbur_state_notifier.dart';
import 'package:qurantafsir_flutter/pages/read_tadabbur/widgets/tadabbur_ayah_card.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/widgets/button.dart';

class ReadTadabburParam {
  ReadTadabburParam({
    required this.surahName,
    required this.surahId,
    this.isFromSurahPage = false,
  });

  final String surahName;
  final int surahId;
  final bool isFromSurahPage;
}

class ReadTadabburPage extends ConsumerWidget {
  final ReadTadabburParam param;
  const ReadTadabburPage({required this.param, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readTadabburProvider(param.surahId));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: QPColors.getColorBasedTheme(
                dark: QPColors.whiteFair,
                light: QPColors.blackMassive,
                brown: QPColors.brownModeMassive,
                context: context,
              ),
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Read Tadabbur",
            style: QPTextStyle.getSubHeading2SemiBold(context),
          ),
          automaticallyImplyLeading: false,
          elevation: 0.7,
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param.surahName,
                  style: QPTextStyle.getSubHeading2SemiBold(context),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: state.listTadabbur.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TadabburAyahCard(
                          ayahNumber: item.ayahNumber,
                          title: item.title,
                          source: item.source.name,
                          createdAt: item.createdAt,
                          tadabburId: item.id,
                          surahNumber: item.surahId,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (param.isFromSurahPage)
            Positioned(
              left: 24,
              bottom: 40,
              child: ButtonBrandSoft(
                title: "Back to Surah",
                leftWidget: const Icon(
                  Icons.menu_book,
                  size: 12,
                  color: QPColors.brandFair,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          if (state.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              height: double.infinity,
              width: double.infinity,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
